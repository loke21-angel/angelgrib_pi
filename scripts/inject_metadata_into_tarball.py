import argparse
import os
import shutil
import tarfile
import tempfile
import xml.etree.ElementTree as ET
from pathlib import Path


def clean_text(node, text: str) -> None:
    if node is not None:
        node.text = text


def patch_metadata_xml(metadata_path: Path) -> None:
    tree = ET.parse(metadata_path)
    root = tree.getroot()

    clean_text(root.find("summary"), "Download NOAA GFS GRIB files and open them in OpenCPN GRIB plugin")
    clean_text(
        root.find("description"),
        "AngelGRIB downloads a small NOAA GFS GRIB2 file and opens it in OpenCPN's GRIB Weather plugin.",
    )

    tree.write(metadata_path, encoding="utf-8", xml_declaration=True)


def patch_tarball(tarball: Path, metadata_xml: Path) -> None:
    if not tarball.exists():
        raise FileNotFoundError(f"tarball does not exist: {tarball}")

    if not metadata_xml.exists():
        raise FileNotFoundError(f"metadata xml does not exist: {metadata_xml}")

    print(f"Patching tarball: {tarball}")

    with tempfile.TemporaryDirectory(prefix="angelgrib_tarball_") as tmp:
        extract_dir = Path(tmp) / "extract"
        extract_dir.mkdir(parents=True, exist_ok=True)

        with tarfile.open(tarball, "r:gz") as tar:
            tar.extractall(extract_dir)

        sidecar_copy = extract_dir / "metadata.xml"
        shutil.copyfile(metadata_xml, sidecar_copy)
        patch_metadata_xml(sidecar_copy)

        for child in extract_dir.iterdir():
            if child.is_dir():
                target = child / "metadata.xml"
                shutil.copyfile(metadata_xml, target)
                patch_metadata_xml(target)
                print(f"Injected package metadata: {target}")

        tmp_tarball = tarball.with_suffix(tarball.suffix + ".tmp")

        with tarfile.open(tmp_tarball, "w:gz") as out:
            for root, dirs, files in os.walk(extract_dir):
                dirs.sort()
                files.sort()
                for filename in files:
                    path = Path(root) / filename
                    arcname = path.relative_to(extract_dir).as_posix()
                    out.add(path, arcname=arcname)

        os.replace(tmp_tarball, tarball)

    verify_tarball(tarball)


def verify_tarball(tarball: Path) -> None:
    print(f"Verifying metadata entries in: {tarball}")

    with tarfile.open(tarball, "r:gz") as tar:
        names = tar.getnames()

    metadata_names = [name for name in names if name.endswith("metadata.xml")]

    if not metadata_names:
        raise RuntimeError(f"No metadata.xml found in tarball after patching: {tarball}")

    for name in metadata_names:
        print(f"  {name}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--metadata", required=True, type=Path)
    parser.add_argument("--tarball", required=True, action="append", type=Path)
    args = parser.parse_args()

    for tarball in args.tarball:
        patch_tarball(tarball, args.metadata)

    print("Metadata injection complete.")


if __name__ == "__main__":
    main()
