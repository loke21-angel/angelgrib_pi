import argparse, tarfile, xml.etree.ElementTree as ET
from pathlib import Path

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--tarball", required=True, type=Path)
    parser.add_argument("--dll-name", required=True)
    args = parser.parse_args()
    with tarfile.open(args.tarball, "r:gz") as tar:
        names = tar.getnames()
        metadata_names = [n for n in names if n.endswith("metadata.xml")]
        dll_names = [n for n in names if n.endswith(args.dll_name)]
        print("Metadata entries:", metadata_names)
        print("DLL entries:", dll_names)
        if not metadata_names: raise SystemExit("metadata.xml not found")
        if not dll_names: raise SystemExit(f"{args.dll_name} not found")
        extracted = tar.extractfile(metadata_names[0])
        xml_bytes = extracted.read()
    root = ET.fromstring(xml_bytes)
    tarball_url = root.findtext("tarball-url", default="").strip()
    print(f"tarball-url: {tarball_url}")
    if "--pkg_repo--" in tarball_url or "--filename--" in tarball_url:
        raise SystemExit("tarball-url still contains template placeholders")
    if "/releases/download/" not in tarball_url:
        raise SystemExit("tarball-url does not point to a GitHub release asset")
    print("Tarball verification OK.")

if __name__ == "__main__":
    main()
