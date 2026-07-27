#!/usr/bin/env python3

#
# check for calibre update
# Author: Adeel Ahmad
# SPDX-License-Identifier: MIT
#

import subprocess
import urllib.request
import urllib.parse
from html.parser import HTMLParser


def compare_versions(v1_str, v2_str):
    """
    Compares two version number strings,

    Args:
    v1_str (str): first version number string.
    v2_str (str): second version number string.

    Returns:
    int: -1 if v1 is smaller,
         1 if v1 is greater, and
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
        self.recording_text = False  # Flag to capture text between <a> and </a>
        self.found = False

    def handle_starttag(self, tag, attrs):
        if self.found:
            return

        if tag == "li":
            self.inside_li = True

        if tag == "a" and self.inside_li:
            # 1. Extract the URL (href)
            for attr, value in attrs:
                if attr == "href":
                    self.first_link = value
                    self.recording_text = True  # Start capturing inner HTML

    def handle_data(self, data):
        # 2. Extract the Inner HTML / Text
        if self.recording_text:
            self.inner_html += data

    def handle_endtag(self, tag):
        if tag == "a" and self.recording_text:
            self.recording_text = False
            self.found = True  # We got everything we need from the first link

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

    def __init__(self, target_text=None):
        super().__init__()
        self.target_text = target_text
        self.found_url = None
        self.current_href = None
        self.is_inside_link = False
        self.captured_text = ""

    def handle_starttag(self, tag, attrs):
        if tag == "a":
            self.is_inside_link = True
            self.captured_text = ""
            for attr, value in attrs:
                if attr == "href":
                    self.current_href = value

    def handle_data(self, data):
        if self.is_inside_link:
            self.captured_text += data

    def handle_endtag(self, tag):
        if tag == "a":
            # Logic: If we are looking for specific text, match it.
            # If not (first hop), just take the first link we find.
            if self.target_text:
                if self.target_text.lower() in self.captured_text.lower():
                    self.found_url = self.current_href
            else:
                if not self.found_url:
                    self.found_url = self.current_href

            self.is_inside_link = False


def get_html(url):
    """
    Fetches the HTML content of the provided URL.

    Args:
    url (str): The URL to fetch the HTML from.

    Returns:
    str: The HTML content of the URL.
    """
    headers = {
        "User-Agent": "Mozilla/5.0"
    }  # Some servers block default python-urllib UA
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response:
            return response.read().decode("utf-8")
    except Exception as e:
        print(f"An error occurred: {e}")
        raise


def fetch_latest_link(base_url):
    """
    Scans the index page at the provided URL and finds the first link.

    Args:
    base_url (str): The base URL to scan.

    Returns:
    tuple: A tuple containing the inner HTML of the first link and the URL of the first link.
    """
    parser = FirstLinkParser()
    try:
        with urllib.request.urlopen(base_url) as response:
            html_content = response.read().decode("utf-8")

        parser.feed(html_content)

        if not parser.first_link:
            print("Error: Could not locate the first link.")
            return ("", "")
    except Exception as e:
        print(f"An error occurred: {e}")
        raise

    return (parser.inner_html.strip(), parser.first_link)


def fetch_download_link(base_url):
    """
    Scans the target page at the provided URL and finds the download link.

    Args:
    base_url (str): The base URL to scan.

    Returns:
    str: The URL of the download link.
    """
    # print(f"Step 1: Scanning index at {base_url}")
    try:
        # HOP 2: Find the "Linux Intel 64-bit binary" link on the sub-page
        target_html = get_html(base_url)
        download_parser = LinkHunter(target_text="Linux Intel 64-bit binary")
        download_parser.feed(target_html)

        if not download_parser.found_url:
            print("Failed to find initial link.")
            return ""

        final_download_url = urllib.parse.urljoin(base_url, download_parser.found_url)
        # print(f"Step 2: Match Found! Binary URL: {final_download_url}")
    except Exception as e:
        print(f"An error occurred: {e}")
        raise

    return final_download_url


def fetch_calibre():
    """
    Fetches the latest version of Calibre from the official website.

    Returns:
    str: The URL of the downloaded Calibre file.
    """
    base_url = "https://download.calibre-ebook.com/"

    try:
        print(f"Accessing {base_url}...")
        link_text, link_rel_href = fetch_latest_link(base_url=base_url)
        # Construct full URL and fetch target page
        full_url = urllib.parse.urljoin(base_url, link_rel_href)

        print("Fetching latest download link...")
        link_text, link_rel_href = fetch_latest_link(base_url=full_url)
        full_url = urllib.parse.urljoin(base_url, link_rel_href)

        download_link = fetch_download_link(full_url)

        result = subprocess.run(
            ["/usr/bin/calibre", "--version"],
            capture_output=True,
            text=True,
            check=True,
            timeout=10,
        )
        recommend = ""
        if result.returncode == 0:
            ver_local = result.stdout.split("(")[1].split(" ")[1].split(")")[0]
            match compare_versions(ver_local, link_text):
                case -1:
                    recommend = (
                        f"A newer version {link_text} is available. You should update!"
                    )
                case 0:
                    recommend = "You have the latest version! :)"
                case 1:
                    recommend = "You have newer version installed locally. Hurray!"

        # Display the extracted metadata
        print("\n--- Extraction Metadata ---")
        print(f"Download URL: {download_link}")
        print(recommend)
        print("---------------------------\n")

    except Exception as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    fetch_calibre()
