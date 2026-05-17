import argparse
import os
import shutil
import tarfile
import tempfile
from pathlib import Path


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

        # Add metadata in both likely locations:
        # 1. archive root: metadata.xml
        # 2. package root: <top-level-dir>/metadata.xml
        shutil.copyfile(metadata_xml, extract_dir / "metadata.xml")

        for child in extract_dir.iterdir():
            if child.is_dir():
                shutil.copyfile(metadata_xml, child / "metadata.xml")
                print(f"Injected package metadata: {child / 'metadata.xml'}")

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
