// vanta-update: Vanta Linux atomic update orchestrator
// Creates a Btrfs snapshot before every pacman transaction.
// On failure, prompts rollback. On success, prunes old snapshots.
//
// Usage:  vanta-update [--check | --apply]
//   --check   check for available updates (exit code 0 = updates available)
//   --apply   download and apply all updates with pre/post snapshots

use std::process::Command;
use std::path::Path;
use std::fs;

const SNAPSHOT_DIR: &str = "/.snapshots";
const CONFIG_DIR: &str = "/etc/snapper/configs";
const ROOT_CONFIG: &str = "vanta-root";

fn main() {
    let args: Vec<String> = std::env::args().collect();
    if args.len() < 2 {
        eprintln!("Usage: vanta-update [--check | --apply]");
        std::process::exit(1);
    }

    match args[1].as_str() {
        "--check" => check_updates(),
        "--apply" => apply_updates(),
        _ => {
            eprintln!("Unknown option: {}. Use --check or --apply.", args[1]);
            std::process::exit(1);
        }
    }
}

fn check_updates() {
    let status = Command::new("checkupdates")
        .status()
        .unwrap_or_else(|_| {
            // fallback: pacman -Qu
            Command::new("pacman")
                .args(["-Qu"])
                .status()
                .expect("failed to check updates")
        });

    std::process::exit(status.code().unwrap_or(1));
}

fn apply_updates() {
    // 1. Verify root is Btrfs
    if !is_btrfs() {
        eprintln!("Vanta atomic updates require Btrfs on /");
        std::process::exit(1);
    }

    // 2. Ensure snapper config exists
    ensure_snapper_config();

    // 3. Pre-update snapshot
    let pre_num = create_snapshot("pre-update");
    println!("Pre-update snapshot #{} created", pre_num);

    // 4. Run pacman
    println!("Applying updates...");
    let status = Command::new("pacman")
        .args(["-Syu", "--noconfirm"])
        .status()
        .expect("failed to run pacman");

    if !status.success() {
        // 5a. Failure - notify about rollback
        eprintln!("Update failed. Rolling back to snapshot #{}", pre_num);
        eprintln!("Run: vanta-rollback {} to restore", pre_num);
        std::process::exit(1);
    }

    // 5b. Post-update snapshot
    let post_num = create_snapshot("post-update");
    println!("Post-update snapshot #{} created", post_num);

    // 6. Update GRUB entries
    Command::new("grub-mkconfig")
        .args(["-o", "/boot/grub/grub.cfg"])
        .status()
        .ok();

    // 7. Prune old snapshots (keep last 5)
    prune_snapshots(5);

    println!("Update complete. System snapshot #{}.", post_num);
}

fn is_btrfs() -> bool {
    let output = Command::new("findmnt")
        .args(["-n", "-o", "FSTYPE", "/"])
        .output()
        .expect("findmnt failed");
    let fstype = String::from_utf8_lossy(&output.stdout).trim().to_string();
    fstype == "btrfs"
}

fn ensure_snapper_config() {
    let config_path = format!("{}/{}", CONFIG_DIR, ROOT_CONFIG);
    if !Path::new(&config_path).exists() {
        Command::new("snapper")
            .args(["-c", ROOT_CONFIG, "create-config", "/"])
            .status()
            .expect("failed to create snapper config");
    }
}

fn create_snapshot(description: &str) -> u64 {
    let output = Command::new("snapper")
        .args(["-c", ROOT_CONFIG, "create", "-d", description, "-t", "single"])
        .output()
        .expect("snapper snapshot failed");

    // Parse snapshot number from output
    let stdout = String::from_utf8_lossy(&output.stdout);
    let stderr = String::from_utf8_lossy(&output.stderr);
    let combined = format!("{}{}", stdout, stderr);

    for line in combined.lines() {
        if let Some(num_str) = line.split_whitespace().find(|w| w.parse::<u64>().is_ok()) {
            if let Ok(n) = num_str.parse::<u64>() {
                return n;
            }
        }
    }
    0
}

fn prune_snapshots(keep: usize) {
    let snapshots_dir = format!("{}/{}", SNAPSHOT_DIR, ROOT_CONFIG);

    if !Path::new(&snapshots_dir).exists() {
        return;
    }

    let mut entries: Vec<_> = fs::read_dir(&snapshots_dir)
        .unwrap()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().map(|t| t.is_dir()).unwrap_or(false))
        .filter_map(|e| {
            e.file_name()
                .to_string_lossy()
                .parse::<u64>()
                .ok()
        })
        .collect();

    entries.sort();

    if entries.len() > keep {
        let to_remove = entries.len() - keep;
        for i in 0..to_remove {
            let num = entries[i];
            Command::new("snapper")
                .args(["-c", ROOT_CONFIG, "delete", &num.to_string()])
                .status()
                .ok();
        }
    }
}
