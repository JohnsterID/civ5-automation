import os
import subprocess
import shutil
import time
import psutil

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
    if os.path.exists(git_repo_path):
        # Get the Git repository head commit hash
        output = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=git_repo_path)
        current_commit_hash = output.strip().decode("utf-8")

        # Fetch the latest changes from the Git repository
        subprocess.check_call(["git", "fetch"], cwd=git_repo_path)

        # Check if there are any changes to the Git repository
        output = subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=git_repo_path)
        latest_commit_hash = output.strip().decode("utf-8")
        if latest_commit_hash != current_commit_hash:
			FIXME: See other comment. Need graceful stop of autoplay.
            print("Stopping autoplay.py due to Git update.")
            # Find the CivilizationV.exe process and terminate it
            for process in psutil.process_iter():
                if process.name() == "CivilizationV.exe":
                    process.terminate()
            break
    else:
        subprocess.check_call(["git", "clone", git_repo_url])

    # Run the build script
    subprocess.check_call(["python", build_script_path, "--config", "debug"], cwd=git_repo_path)

    # Move the built files to the required MOD folder location
    for file_name in os.listdir(src_folder_path):
        src_file_path = os.path.join(src_folder_path, file_name)
        dest_file_path = os.path.join(dest_folder_path1, file_name)
        shutil.copy(src_file_path, dest_file_path)

    # Remove CvGameCore_Expansion2.dll and LUA folder from the MOD folder
    if os.path.exists(os.path.join(dest_folder_path1, "CvGameCore_Expansion2.dll")):
        os.remove(os.path.join(dest_folder_path1, "CvGameCore_Expansion2.dll"))
    if os.path.exists(os.path.join(dest_folder_path1, "LUA")):
        shutil.rmtree(os.path.join(dest_folder_path1, "LUA"))

    # FIXME: Add a way to gracefully stop autoplay.py if there is a git update before building.
    #        Also, check if CivilizationV.exe is still running from the autoplay script before trying to run it again.
    #        Ideally, CivilizationV.exe is stopped with the graceful stop of autoplay.py as we don't want it running when we build either as we need the resources.
    # Run the autoplay script
    while True:
        # Check if CivilizationV.exe is still running from the previous autoplay session
        for process in psutil.process_iter():
            if process.name() == "CivilizationV.exe" and process.cwd() == dest_folder_path1:
                print("Waiting for CivilizationV.exe to exit before starting autoplay.py.")
                time.sleep(60)
                break
        else:
            subprocess.check_call(["python", "autoplay.py"], cwd=dest_folder_path1)
            break

    # Wait for 1 hour before checking for updates again
    time.sleep(3600)
