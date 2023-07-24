import os
import requests
from bs4 import BeautifulSoup

cookies = {
    "buckler_id": os.getenv("BUCKLER_ID", ""), "",
    "buckler_r_id": os.getenv("BUCKLER_R_ID", ""),
    "buckler_praise_date": os.getenv("BUCKLER_PRAISE_DATE", ""),
}

headers = {
    "User-Agent": os.getenv("USER_AGENT", "Mozilla/5.0 (X11; Linux x86_64; rv:109.0) Gecko/20100101 Firefox/115.0")
}

url = "https://www.streetfighter.com/6/buckler/profile/1052558378/play"

s = requests.Session()

response = s.get(url, cookies=cookies, headers=headers)
print(response.status_code)

soup = BeautifulSoup(response.text, 'html.parser')

print(soup)

# Now you can find elements on the page using BeautifulSoup's methods.
# For example, to find a specific tag (replace 'tag_name' and 'tag_id' with actual values):
element = soup.find('script', attrs={'id': '__NEXT_DATA__'})

if element != None:
    with open('data.json', 'w') as file:
        file.write(element.string)
else:
    print('error, script tag __NEXT_DATA__ couldnt be found')
