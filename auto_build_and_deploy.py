import os
import subprocess
import shutil
import time

# Specify the Git repository URL and local folder path
git_repo_url = "https://github.com/LoneGazebo/Community-Patch-DLL.git"
git_repo_path = "Community-Patch-DLL"

# Specify the build script file path
build_script_path = "build_vp_clang.py"

# Specify the source and destination folder paths for the built files
src_folder_path = "Community-Patch-DLL/bin/Debug"
dest_folder_path1 = os.path.expanduser(r"~\Documents\My Games\Sid Meier's Civilization 5\MODS\(1) Community Patch")

while True:
    # Check for updates in the Git repository
    subprocess.check_call(["git", "clone", git_repo_url]) if not os.path.isdir(git_repo_path) else None
    subprocess.check_call(["git", "pull"], cwd=git_repo_path)

    # Run the build script
    subprocess.check_call(["python", build_script_path, "--config", "debug"], cwd=git_repo_path)

    # Move the built files to the required MOD folder location
    for file_name in os.listdir(src_folder_path):
        src_file_path = os.path.join(src_folder_path, file_name)
        dest_file_path = os.path.join(dest_folder_path1, file_name)
        shutil.copy(src_file_path, dest_file_path)

    # Remove CvGameCore_Expansion2.dll and LUA folder from the MOD folder
    os.remove(os.path.join(dest_folder_path1, "CvGameCore_Expansion2.dll"))
    shutil.rmtree(os.path.join(dest_folder_path1, "LUA"))

    # Run the autoplay script
    subprocess.check_call(["python", "autoplay.py"], cwd=dest_folder_path1)

    # Wait for 1 hour before checking for updates again
    time.sleep(3600)
