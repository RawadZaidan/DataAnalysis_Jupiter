import os
import requests
from url_lookups import URLS


def download_files(output_folder):
    os.makedirs(output_folder, exist_ok=True) # if folder doesn't exists, it creates one
    for url_enum in URLS:
        url = url_enum.value
        table_name = url_enum.name
        try:
            r = requests.get(url, allow_redirects=True)
            r.raise_for_status()
            file_name = f"{table_name}.csv"
            file_path = os.path.join(output_folder, file_name)
            with open(file_path, 'wb') as file:
                file.write(r.content)
            print(f"Downloaded {file_name} to {output_folder}")
        except Exception as e:
            print(f"Failed to download file {table_name}: {str(e)}")

def find_csv_files(directory):
   csv_files = []
   for root, _, files in os.walk(directory):
      for file in files:
         if file.endswith('.csv'):
            csv_files.append(os.path.join(root, file))
   return csv_files