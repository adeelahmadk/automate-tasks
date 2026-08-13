#!/usr/bin/env python3

import os
import sys
import time
import tempfile
import subprocess
import urllib.request
import urllib.parse
from html.parser import HTMLParser


class Colors:
    BLACK = 30
    RED = 31
    GREEN = 32
    YELLOW = 33
    BLUE = 34
    MAGENTA = 35
    CYAN = 36
    WHITE = 37


class Styles:
    NORMAL = 0
    BOLD = 1
    UNDERLINE = 4


# Reset code
RESET = "\033[0m"


def color_text(text: str, color: int, style: int = Styles.NORMAL) -> str:
    """Add color and style for terminal"""
    return f"\033[{style};{color}m{text}{RESET}"


def ask_yes_no(question: str) -> bool:
    """Ask a yes/no question and return answer"""
    while True:
        reply = input(f"{question} (y/n): ").strip().lower()

        if reply in ("y", "yes"):
            return True
        if reply in ("n", "no"):
            return False

        print(color_text("Invalid input.", Colors.RED), "Please enter 'y' or 'n'.")


def compare_versions(v1_str: str, v2_str: str) -> int:
    """
    Compares two version number strings,

    Args:
    v1_str (str): first version number string.
    v2_str (str): second version number string.

    Returns:
    int: -1 if v1 is smaller,
          1 if v1 is greater,
          0 if both are equal.
    """
    v1_parts = list(map(int, v1_str.split(".")))
    v2_parts = list(map(int, v2_str.split(".")))

    # Pad shorter list with zeros so comparison works correctly
    max_len = max(len(v1_parts), len(v2_parts))
    v1_parts.extend([0] * (max_len - len(v1_parts)))
    v2_parts.extend([0] * (max_len - len(v2_parts)))

    for p1, p2 in zip(v1_parts, v2_parts):
        if p1 > p2:
            return 1
        elif p1 < p2:
            return -1
    return 0


class FirstLinkParser(HTMLParser):
    """
    Parses HTML to find the first link on a page.

    Attributes:
    first_link (str): The URL of the first link found.
    inner_html (str): The inner HTML of the first link.
    inside_li (bool): Flag to indicate if we are inside a list item.
    recording_text (bool): Flag to capture text between <a> and </a>.
    found (bool): Flag to indicate if we have found the first link.
    """

    def __init__(self):
        super().__init__()
        self.first_link = None
        self.inner_html = ""
        self.inside_li = False
        self.recording_text = False  # Flag: capture text between <a> and </a>
        self.found = False

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if self.found:
            return

        if tag == "li":
            self.inside_li = True

        if tag == "a" and self.inside_li:
            # Extract the URL (href)
            for attr, value in attrs:
                if attr == "href":
                    self.first_link = value
                    self.recording_text = True  # Start capturing inner HTML

    def handle_data(self, data: str) -> None:
        # Extract the Inner HTML / Text
        if self.recording_text:
            self.inner_html += data

    def handle_endtag(self, tag: str) -> None:
        if tag == "a" and self.recording_text:
            self.recording_text = False
            self.found = True  # Done extracting URL & Text from the first link

        if tag == "li":
            self.inside_li = False


class LinkHunter(HTMLParser):
    """
    Parses HTML to find a specific link on a page.

    Attributes:
    target_text (str): The text to search for in the links.
    found_url (str): The URL of the first link found.
    current_href (str): The current href being processed.
    is_inside_link (bool): Flag to indicate if we are inside a list item.
    captured_text (str): The text captured between <a> and </a>.
    """

    def __init__(self, target_text: str | None = None):
        super().__init__()
        self.target_text = target_text
        self.found_url = None
        self.current_href = None
        self.is_inside_link = False
        self.captured_text = ""

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag == "a":
            self.is_inside_link = True
            self.captured_text = ""
            for attr, value in attrs:
                if attr == "href":
                    self.current_href = value

    def handle_data(self, data: str) -> None:
        if self.is_inside_link:
            self.captured_text += data

    def handle_endtag(self, tag: str) -> None:
        if tag == "a":
            if self.target_text:
                # If we are looking for specific text, match it.
                if self.target_text.lower() in self.captured_text.lower():
                    self.found_url = self.current_href
            else:
                # If not (first hop), just take the first link we find.
                if not self.found_url:
                    self.found_url = self.current_href

            self.is_inside_link = False


def get_html(url: str) -> str:
    """
    Fetches the HTML content of the provided URL.

    Args:
    url (str): The URL to fetch the HTML from.

    Returns:
    str: The HTML content of the URL.
    """
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0"
    }  # Some servers block default python-urllib UA

    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response:
            return response.read().decode("utf-8")
    except Exception as e:
        print(f"An error occurred: {e}")
        raise


def fetch_latest_link(base_url: str) -> tuple[str, str]:
    """
    Scans the index page at the provided URL and finds the first link.

    Args:
    base_url (str): The base URL to scan.

    Returns:
    tuple: A tuple containing the inner HTML of the first link and the URL of the first link.
    """
    parser = FirstLinkParser()

    try:
        html_content = get_html(base_url)
        parser.feed(html_content)

        if not parser.first_link:
            print("Error: Could not locate the first link.")
            return ("", "")
    except Exception as e:
        print(f"An error occurred: {e}")
        raise

    return (parser.inner_html.strip(), parser.first_link)


def fetch_download_link(base_url: str) -> str:
    """
    Scans the target page at the provided URL and finds the download link.

    Args:
    base_url (str): The base URL to scan.

    Returns:
    str: The URL of the download link.
    """
    try:
        # HOP 2: Find the "Linux Intel 64-bit binary" link on the sub-page
        target_html = get_html(base_url)
        download_parser = LinkHunter(target_text="Linux Intel 64-bit binary")
        download_parser.feed(target_html)

        if not download_parser.found_url:
            print("Failed to find initial link.")
            return ""

        final_download_url = urllib.parse.urljoin(base_url, download_parser.found_url)
    except Exception as e:
        print(f"An error occurred: {e}")
        raise

    return final_download_url


def check_update_pipeline() -> tuple[str, str, str]:
    """
    Checks the official website for the latest version of Calibre.

    Returns:
    str: The local Calibre version.
    str: The Calibre version available online.
    str: The download URL of the Calibre.
    """
    base_url = "https://download.calibre-ebook.com/"

    try:
        print(f"Accessing {base_url}...")
        _, link_rel_href = fetch_latest_link(base_url=base_url)
        # Construct full URL and fetch target page
        full_url = urllib.parse.urljoin(base_url, link_rel_href)

        print("Fetching latest download link...")
        ver_remote, link_rel_href = fetch_latest_link(base_url=full_url)
        full_url = urllib.parse.urljoin(base_url, link_rel_href)

        download_link = fetch_download_link(full_url)

        result = subprocess.run(
            ["/usr/bin/calibre", "--version"],
            capture_output=True,
            text=True,
            check=True,  # throw exception for non-zero exit code
            timeout=10,
        )
        ver_local = result.stdout.split("(")[1].split(" ")[1].split(")")[0]
        return (ver_local, ver_remote, download_link)

    except Exception as e:
        print(f"An error occurred: {e}")

    return ("", "", "")


def download_tarball(url: str, dest_folder: str) -> str | None:
    """Downloads the Calibre tarball from a URL to a specified destination folder."""
    filename = url.split("/")[-1]
    target_path = os.path.join(dest_folder, filename)

    print(f"\nDownloading: {url}")
    try:
        with (
            urllib.request.urlopen(url) as response,
            open(target_path, "wb") as out_file,
        ):
            total_size = int(response.headers.get("content-length", 0))
            downloaded = 0
            block_size = 1024 * 1024  # 1MB

            while True:
                buffer = response.read(block_size)
                if not buffer:
                    break
                downloaded += len(buffer)
                out_file.write(buffer)

                if total_size:
                    percent = (downloaded / total_size) * 100
                    print(
                        f"\r{color_text(f'Progress: {percent:.1f}%', Colors.CYAN)} ({downloaded // (1024 * 1024)}MB / {total_size // (1024 * 1024)}MB)",
                        end="",
                    )
            print("\nDownload complete.")
        return target_path
    except Exception as e:
        print(f"\nFailed to download file: {e}", file=sys.stderr)
        return None


def install_calibre(tarball_path: str) -> bool:
    """Automates extraction and post-installation of Calibre with safe automatic rollback."""
    target_dir = "/opt/calibre"

    # Generate a unique timestamped backup directory name
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    backup_dir = f"/opt/calibre_backup_{timestamp}"
    backup_created = False

    print("\n")

    try:
        # Step 1: Ensure target dir exists so we can safely move/backup things
        subprocess.run(
            ["/usr/bin/sudo", "/usr/bin/mkdir", "-p", target_dir], check=True
        )

        # Step 2: If files exist in target_dir, safely move them to our backup folder
        if os.listdir(target_dir):
            print(
                "\n\u2192 ",
                color_text(
                    f"Existing files found. Backing up to {backup_dir}...", Colors.CYAN
                ),
            )
            subprocess.run(
                ["/usr/bin/sudo", "/usr/bin/mkdir", "-p", backup_dir], check=True
            )
            # Move contents out using bash wildcard expansion
            subprocess.run(
                [
                    "/usr/bin/sudo",
                    "/usr/bin/bash",
                    "-c",
                    f"mv {target_dir}/* {backup_dir}/",
                ],
                check=True,
            )
            backup_created = True

        # Step 3: Extract the tarball into the now-empty target directory
        print("\n\u2192 ", color_text("Extracting tarball contents...", Colors.CYAN))
        subprocess.run(
            ["/usr/bin/sudo", "/usr/bin/tar", "xvf", tarball_path, "-C", target_dir],
            check=True,
        )

        # Step 4: Run the post-install configuration script
        print(
            "\n\u2192 ", color_text("Running post-installation scripts...", Colors.CYAN)
        )
        subprocess.run(
            ["/usr/bin/sudo", f"{target_dir}/calibre_postinstall"], check=True
        )

        # Clean up: If installation succeeded, wipe the old backup directory safely
        if backup_created:
            print(
                "\n\u2192 ",
                color_text(
                    "Installation complete. Purging old temporary backup folder.",
                    Colors.CYAN,
                ),
            )
            subprocess.run(
                ["/usr/bin/sudo", "/usr/bin/rm", "-rf", backup_dir], check=True
            )

        print(
            color_text(
                "\n*** Calibre installation completed successfully. ***",
                Colors.GREEN,
                Styles.BOLD,
            )
        )
        return True

    except (subprocess.CalledProcessError, Exception) as e:
        print(
            f"\n{color_text('[ERROR]', Colors.RED, Styles.BOLD)} Step failed during installation: {e}",
            file=sys.stderr,
        )

        # ROLLBACK PROCEDURE TRIGGER
        if backup_created:
            print(
                f"{color_text('[ROLLBACK]', Colors.MAGENTA, Styles.BOLD)} Reverting system changes. Restoring previous state from {backup_dir}...",
                file=sys.stderr,
            )
            try:
                # Wipe the broken/failed installation contents cleanly
                subprocess.run(
                    ["/usr/bin/sudo", "/usr/bin/bash", "-c", f"rm -rf {target_dir}/*"],
                    check=True,
                )
                # Restore the files we stashed away prior to extraction
                subprocess.run(
                    [
                        "/usr/bin/sudo",
                        "/usr/bin/bash",
                        "-c",
                        f"mv {backup_dir}/* {target_dir}/",
                    ],
                    check=True,
                )
                # Clear out the now empty temporary directory
                subprocess.run(
                    ["/usr/bin/sudo", "/usr/bin/rm", "-rf", backup_dir], check=True
                )
                print(
                    f"{color_text('[ROLLBACK]', Colors.MAGENTA, Styles.BOLD)} System restored to previous state successfully.",
                    file=sys.stderr,
                )
            except subprocess.CalledProcessError as rollback_error:
                print(
                    f"{color_text('[CRITICAL]', Colors.RED, Styles.BOLD)} Rollback pipeline failed completely: {rollback_error}",
                    file=sys.stderr,
                )
        else:
            print(
                f"{color_text('[ROLLBACK]', Colors.MAGENTA, Styles.BOLD)} No pre-existing installation files found to restore. Clean directory kept.",
                file=sys.stderr,
            )

        return False


def run_upgrade_pipeline(url: str) -> bool:
    """Coordinates download and installation inside a clean temporary folder."""
    with tempfile.TemporaryDirectory() as tmpdir:
        downloaded_file = download_tarball(url, tmpdir)
        if not downloaded_file:
            print(color_text("Aborting installation: Download failed.", Colors.RED))
            return False
        return install_calibre(downloaded_file)


def upgrade_calibre() -> None:
    upgrade_available: bool = False

    try:
        ver_local, ver_remote, download_link = check_update_pipeline()
        if not download_link:
            print("Couldn't retrieve the download link.")
            return

        recommend = ""
        match compare_versions(ver_local, ver_remote):
            case -1:
                recommend = color_text(
                    f"A newer version {ver_remote} is available. You should update!",
                    Colors.CYAN,
                )
                upgrade_available = True
            case 0:
                recommend = (
                    f"You have the latest version! {color_text(':)', Colors.GREEN)}"
                )
            case 1:
                recommend = "You have newer version installed locally. Hurray!"

        # Display the extracted metadata
        head_cap = "Extracted Info"
        len_head_cap = len(head_cap)

        if (len_link := len(download_link)) % 2 != 0:
            len_link = len_link + 1

        half_headr_bar = "-" * ((len_link - len_head_cap - 2) // 2)

        print("\n")
        print(
            half_headr_bar,
            color_text(f" {head_cap} ", Colors.YELLOW, Styles.BOLD),
            half_headr_bar,
            sep="",
        )
        print(f"Installed: {ver_local}")
        print(f"Available: {ver_remote}")
        print(f"Download URL:\n{download_link}")
        print(recommend)
        print("-" * len_link, "\n")

        if upgrade_available and ask_yes_no(f"Do you want to upgrade to {ver_local}?"):
            if not run_upgrade_pipeline(download_link):
                print(
                    f"\n{color_text('Failed to upgrade Calibre.', Colors.RED, Styles.BOLD)}"
                )

    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    upgrade_calibre()
