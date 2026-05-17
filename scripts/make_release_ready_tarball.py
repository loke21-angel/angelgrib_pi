import argparse, os, shutil, tarfile, tempfile, xml.etree.ElementTree as ET
from pathlib import Path

SUMMARY = "Download NOAA GFS weather GRIB files and open them in OpenCPN GRIB plugin"
DESCRIPTION = "Angel CPN Weather downloads a small NOAA GFS GRIB2 file and opens it in OpenCPN's GRIB Weather plugin."

def get_or_create(root, name):
    node = root.find(name)
    if node is None:
        node = ET.SubElement(root, name)
    return node

def patch_metadata_xml(metadata_path, tarball_filename, repo, tag, display_name):
    tree = ET.parse(metadata_path)
    root = tree.getroot()
    get_or_create(root, "name").text = display_name
    get_or_create(root, "summary").text = SUMMARY
    get_or_create(root, "description").text = DESCRIPTION
    release_url = f"{repo}/releases/download/{tag}/{tarball_filename}"
    get_or_create(root, "tarball-url").text = release_url
    get_or_create(root, "info-url").text = repo
    get_or_create(root, "source").text = repo
    tree.write(metadata_path, encoding="utf-8", xml_declaration=True)
    return release_url

def patch_tarball(tarball, metadata_xml, repo, tag, display_name):
    print(f"Patching tarball: {tarball}")
    with tempfile.TemporaryDirectory(prefix="angel_cpn_weather_tarball_") as tmp:
        extract_dir = Path(tmp) / "extract"
        extract_dir.mkdir(parents=True, exist_ok=True)
        with tarfile.open(tarball, "r:gz") as tar:
            tar.extractall(extract_dir)
        root_metadata = extract_dir / "metadata.xml"
        shutil.copyfile(metadata_xml, root_metadata)
        release_url = patch_metadata_xml(root_metadata, tarball.name, repo, tag, display_name)
        for child in extract_dir.iterdir():
            if child.is_dir():
                target = child / "metadata.xml"
                shutil.copyfile(metadata_xml, target)
                release_url = patch_metadata_xml(target, tarball.name, repo, tag, display_name)
                print(f"Injected package metadata: {target}")
        tmp_tarball = tarball.with_suffix(tarball.suffix + ".tmp")
        with tarfile.open(tmp_tarball, "w:gz") as out:
            for current_root, dirs, files in os.walk(extract_dir):
                dirs.sort(); files.sort()
                for filename in files:
                    path = Path(current_root) / filename
                    out.add(path, arcname=path.relative_to(extract_dir).as_posix())
        os.replace(tmp_tarball, tarball)
    print(f"Release URL embedded: {release_url}")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--metadata", required=True, type=Path)
    parser.add_argument("--repo", required=True)
    parser.add_argument("--tag", required=True)
    parser.add_argument("--dll-name", required=True)
    parser.add_argument("--display-name", required=True)
    parser.add_argument("--tarball", required=True, action="append", type=Path)
    args = parser.parse_args()
    for tarball in args.tarball:
        patch_tarball(tarball, args.metadata, args.repo.rstrip("/"), args.tag, args.display_name)
    print("Release-ready tarball generation complete.")

if __name__ == "__main__":
    main()
