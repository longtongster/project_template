from pathlib import Path

from utils.data_utils import get_logger, initialize_dvc, initialize_dvc_storage, make_new_data_version

dvc_remote_name = "s3-storage"
dvc_remote_url = "s3://dvc-test-svw-2"
#dvc_remote_url = "s3://dvc-test-svw/datasets"
dvc_raw_data_folder = "data/raw"


def version_data() -> None:
    logger = get_logger(Path(__file__).name)
    initialize_dvc()


if __name__ == "__main__":
    version_data()

    initialize_dvc_storage(dvc_remote_name=dvc_remote_name, dvc_remote_url=dvc_remote_url)

    make_new_data_version(dvc_raw_data_folder, dvc_remote_name)
