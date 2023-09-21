import requests
import zipfile
import os

class FileDownloader:
   def __init__(self, download_link):
      self.download_link = download_link

   def download_file(self, save_path):
      try:
         response = requests.get(self.download_link) #we used requests library to send and HTTP GET request to the download link stored in self.download_link and we store it in the variable response
         with open(save_path, 'wb') as file:  # 'wb':mode for writing binary data(suitable for zip files) and we use here with to ensure the file is properly closed after it's done being written
            file.write(response.content) #writes the content of HTTP response to the open file (saves the downloaded file to the save_path)
         print(f"File downloaded and saved to {save_path}")
      except Exception as e:
         print(f"Failed to download file: {str(e)}")

   def unzip_file(self, zip_path, extract_dir):
      try:
         with zipfile.ZipFile(zip_path, 'r') as zip_ref: #used the zipfile library to open the zip file at the zip_path in read mode. with is used to ensure file is closed after extraction
            zip_ref.extractall(extract_dir) #extract all contents of the opened zip file to the extract_dir directory
         print(f"File unzipped to {extract_dir}")
      except Exception as e:
         print(f"Failed to unzip file: {str(e)}")
   
   def find_csv_file(self, directory):
      for root, dirs, files in os.walk(directory): #os.walk to traverse through the dir and its sub dir. root: current dir. dirs: list of sub dirs. files: a list of files in the current dir
         for file in files: #iterate over the list of files in the current dir
            if file.endswith('.csv'):
               return os.path.join(root, file) #return the full path to that CSV file by joining root and the file itself to get the complete path to the csv file
      return None # if nothing ending with .csv is found
         

   # we are executing all the functions : download, unzip and search for csv file and finally returning the path to the csv files within the extracted dir
   def download_and_extract_csv(self, save_path, extract_dir):
      self.download_file(save_path)
      self.unzip_file(save_path, extract_dir)
      csv_file_path = self.find_csv_file(extract_dir)
      return csv_file_path