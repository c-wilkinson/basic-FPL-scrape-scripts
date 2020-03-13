import requests
import getpass
import json
import time

FplSession = requests.session()

def Authenticate():
    CredentialUser = input("Username: ")
    CredentialPassword = getpass.getpass(prompt='Password: ', stream=None)
    URI = 'https://users.premierleague.com/accounts/login/'
    FplSession.post(URI, data={
        'password': CredentialPassword,
        'login': CredentialUser,
        'redirect_uri': 'https://fantasy.premierleague.com/a/login',
        'app': 'plfpl-web'
        }
    )

def ScrapeFPLWebSite(url):
    response = FplSession.get(url)
    # Sleep, be as kind as possible to the FPL servers!
    time.sleep(2.5)
    return json.loads(response.text)

Authenticate()
test = ScrapeFPLWebSite('https://fantasy.premierleague.com/api/leagues-classic/36351/standings/?page_standings=1')
print(test)
