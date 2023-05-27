{{ ocean.use_conn("Snowflake") }} 

import string
import numpy as np
import requests                 # html requests
from bs4 import BeautifulSoup   # html parsing
import pandas as pd             # read in Excel
from time import sleep          # for breaks in between reading each URLs
from datetime import datetime
from multiprocessing import Pool
import re
from urllib.parse import urlparse, urljoin
from urllib.request import urlopen
import datetime as dt
#from dataflow import db
import os
import sqlalchemy
from sqlalchemy import create_engine
import pandas as pd
import snowflake.connector
 
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from snowflake.connector.pandas_tools import write_pandas
from snowflake.connector.pandas_tools import pd_writer

# pandas setting for display
pd.set_option("display.max_rows", None, "display.max_columns", None)

SNK_ACCOUNT = 'ubisoft.us-east-1'
USER = '{{ ocean.conns["Snowflake_AC"].account }}' # e.g.: <service_account>@ubisoft.com, read info from external connection
PASSPHRASE = '{{ ocean.conns["Snowflake_AC"].password }}' # read info from external connection
PRIVATEKEY = '''{{ ocean.conns["Snowflake_AC"].private_key }}''' # read info from external connection
DATABASE = 'SANDBOX'
WAREHOURSE = 'NCSA_SPA_COMMON'
SCHEMA = 'NCSA_SPA_SUPPLY_CHAIN_PRIVATE'
ROLE = 'SNK_F_NCSASPA_SB_DEV'


p_key= serialization.load_pem_private_key(
    bytearray(PRIVATEKEY, 'utf-8'),
    password=PASSPHRASE.encode(),
    backend=default_backend())

pkb = p_key.private_bytes(
    encoding=serialization.Encoding.DER,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.NoEncryption())

ctx = snowflake.connector.connect(
    user = USER,
    account = SNK_ACCOUNT,
    private_key = pkb,
    warehouse = WAREHOURSE,
    database = DATABASE,
    schema = SCHEMA,
    role = ROLE
)
    
cur = ctx.cursor()


user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/75.0.3770.142 Safari/537.36'
headers = {'User-Agent': user_agent}
proxies = {
    "https": "http://proxy.ubisoft.org:3128",
    "http": "http://proxy.ubisoft.org:3128"
    }
    
cookies = {"cookie":"birthtime=568022401; MUID=30BB4442E0B66943272449B3E4B66F32; _ga=GA1.2.825220288.1570735774; ClicktaleReplayLink=https://dmz01.app.clicktale.com/Player.aspx?PID=1009&UID=2544939305730875&SID=2544939305730875; MC1=GUID=2b82b847156b4524b9723c7025510074&HASH=2b82&LV=202003&V=4&LU=1585593566758; optimizelyEndUserId=oeu1590533721626r0.845508029644928; _cs_c=1; AAMC_mscom_0=REGION%7C9; aam_uuid=86664042096773864221896308562272211691; IR_PI=81b74c1b-d091-11ea-871f-42010a246fdb%7C1598652114945; AADNonce=a2838f16-ee9f-45d6-adcb-b52ea38b4e83.637346047514059601; IR_gbd=microsoft.com; fptctx2=H3ihr9e92IdW6yd1ZgQ9S6iHaRiejIdk0aIJJ5j7uH6R0jawB3YOIdjCx2k4p%252brcvVm%252fRvej4Uma5%252fMTyVEqZpTExemeW74EBrCh%252fBUkgYmJ8Ut%252frSqE6O%252btfUhCYackY6BZf4zyFUv0p%252fFNC82EsMS0NtuGlwn5Aye43h3U2kEGuf%252fHHQr2pRnYgP6wc8ZYvGaOsNRlAEKtnmHRvSAlBA0aFqCBso%252fOf4LQDlNhluJmIuG4ByG2zSCigq6esTIyyLZZxU3AyaI71tWIhK2FMePxknBgp4HTXkyBcLv0umYpIp2LtUoOF4Xk5%252b12ixmx; check=true; AMCVS_EA76ADE95776D2EC7F000101%40AdobeOrg=1; graceIncr=0; IR_7796=1599099294292%7C0%7C1599097858319%7C%7C; mslocale={'r':'1'|'u':'en-us'}; uhf_hide_epb=true; mbox=PC#8ae9e122feeb4661ab7aaec3887bccf2.35_0#1662347419|session#bf882391db8e4b78995ab812d15357d9#1599104478; AMCV_EA76ADE95776D2EC7F000101%40AdobeOrg=-894706358%7CMCIDTS%7C18508%7CMCMID%7C87103818590641632571942516022783753188%7CMCAAMLH-1599694687%7C9%7CMCAAMB-1599707418%7CRKhpRz8krg2tLO6pguXWp5olkAcUniQYPHaMWWgdJ3xzPWQmdj0y%7CMCOPTOUT-1599109818s%7CNONE%7CMCAID%7CNONE%7CvVersion%7C2.3.0%7CMCCIDH%7C1924333188; IR_7593=1599116926112%7C0%7C1599115994939%7C%7C; _cs_id=8646c1cc-d4fe-ad0d-eecd-5dae43817e73.1597950328.20.1599116926.1599115197.1594299326.1632114328541.Lax.0; _cs_s=9.1; MS0=39dfe6e61f9048a6aa81d90ee7410f07; _uetsid=b9f0d83d80d5373e18a59d725f0b7b19; _uetvid=bc6691323de7d4f7797ed7eb690c6072; IR_7803=1599118261955%7C0%7C1599116770592%7C%7C"}



#ctx.cursor().execute('USE warehouse NCSA_SPA_COMMON')
ctx.cursor().execute('USE SANDBOX.NCSA_SPA_SUPPLY_CHAIN_PRIVATE')

sql = "SELECT LINK FROM  AC_PRICE_URL_MASTER_SOURCE_API_MS"
result = ctx.cursor().execute(sql)  

gamelist = pd.DataFrame(result)[0]

# debug
for i in gamelist:
    print(i)

# define div that contains title and price
priceClass= 'ProductDetailsHeader-module__detailContainerRight___ZvBLD'
srOnly2 = 'Price-module__boldText___vmNHu Price-module__moreText___q5KoT Price-module__listedDiscountPrice___67yG1'
srOnly = 'Price-module__boldText___vmNHu Price-module__moreText___q5KoT'
myClass = 'ProductDetailsHeader-module__detailContainer___rxkiz'
XBSdiv = 'ModuleContainer-module__container___pkhPl DescriptionModulesContainer-module__rowMargin___ZZVo4'
# define today's date
todayDate = dt.date.today().strftime('%Y-%m-%d')

def scrape(url):
    df = pd.DataFrame()
    for i in url:
        try:
            print("Scraping for ", i) # check which URL went wrong
            lower_i = i.lower() # make url lowercase for checking countries and currency
            
            if 'en-us' in lower_i:
                countries = 'US'
                currency = 'US'
            elif 'en-ca' in lower_i:
                countries = 'CA'
                currency = 'CA'
            elif 'pt-br' in lower_i:
                countries = 'BR'
                currency = 'BR'
            elif 'es-mx' in lower_i:
                countries = 'MX'
                currency = 'MX'
                
            r = requests.get(i,headers=headers,cookies=cookies,proxies=proxies)
            print("test ")

            soup = BeautifulSoup(r.text, 'lxml')
            # soup will try to find the div with class defined. If fails here, go to the MS url and see if the class was changed
            if soup.find('div', {"class":  myClass}) is not None:
                title = soup.find('div', {"class":  myClass}).find('h1').text.strip().replace('—','-').replace('–','-').replace('Edição','Edition').replace("'","\'\'").replace('ⓡ','').replace('“','').replace('”','').replace('®','').replace('™','')
                print(title)
            if soup.find('div', {"class":  myClass}) is not None:
                if soup.find('div', {"class":  priceClass}).find('span',class_=srOnly) is not None:
                    current_price = soup.find('div', {"class":  priceClass}).find('span',class_=srOnly).text.split('+')[0]
                    print(current_price) 
                else: 
                    current_price = soup.find('div', {"class":  priceClass}).find('span',class_=srOnly2).text.split('+')[0]
                    print(current_price)
            else: 
                current_price = None                   
                print('no price in myClass')

            # Here to check the platform
            print('Finding Platform for', title)        
            div_2 = soup.find_all('div', attrs={'class': XBSdiv}) # finding 
            if len(div_2) > 0:
                if 'Xbox Series X|S' in str(div_2[0]):
                    print("Found XBS only")
                    df = df.append(pd.DataFrame([[title, 'XBS', countries, current_price, currency]], 
                                                columns=['SKU','Platform','Country','Price','Currency']), ignore_index=True)
                else:
                    print("Found XB1")
                    df = df.append(pd.DataFrame([[title, 'Xbox One', countries, current_price, currency]], 
                                                columns=['SKU','Platform','Country','Price','Currency']), ignore_index=True)
                    # Here to check if XBS available
                    if len(div_2) >= 2:
                        if 'Xbox Series X|S' in str(div_2[1]):
                            print('Found XBS after XB1')
                            df = df.append(pd.DataFrame([[title, 'XBS', countries, current_price, currency]], 
                                                        columns=['SKU','Platform', 'Country','Price','Currency']), ignore_index=True)
                        else:
                            print('Found div but no XBS.')
                    else:
                        print('No XBS at all.')
            else: 
                df = df.append(pd.DataFrame([[title, 'Xbox One', countries, current_price, currency]], 
                                                columns=['SKU','Platform','Country','Price','Currency']), ignore_index=True)

            sleep(np.random.uniform(2,7)) # don't run too often to faile the security check
            df.insert(1,'Date',todayDate)
        except:
            print("Failed and passed for ", i)
            pass
        
    return df

p_df = scrape(gamelist)
print("Scraping finished, here's what we got: ")
print(p_df)
print("starting price cleaning")

# clean function will go over the strings we scraped and try to extract the price from it.
# here is two list that contains free or empty indecator, add more if found new words in the future
free_list = ['Gratuito','Free','Gratis','Free trial']
none_list = ['', 'no price']

def clean_price(x):
    print('Trying to convert: ', x)
    if (x == None)|(x in none_list):
        result = None
    elif x in free_list:
        result = 0
    elif True in [char.isdigit() for char in x]: # check if there is no number in the string
        if ('€' in x):
            result = float(x.replace(',','').split('pour')[-1].split('€')[0].strip().split(' ')[0])/100
        elif ('ARS' in x):
            result = float(x.replace(',','').replace('.','').split('$')[-1].strip().split(' ')[0])/100
        # below we check if there is any words before '$'
        # Our goal is to keep numbers only in the string and convert the string into float
        # Hence we don't need and ',' or ';'
        # Notice we are taking the [-1] after split, that is because we want to filter out the original price when there is a discount
        # The the discount prise usually came after the original price
        elif x.replace(',','').split('$')[0] != '':
            if x.replace(',','').split(' ')[-1].split('$')[0].lower() == 'r':
            # having 'R' before '$' means it's using ',' to identify decimal (ex. R$1,232,00 this is actually $1,232.00)
                result = float(x.replace(',','').replace(';','').split('$')[-1].strip().split(' ')[0])
            else: 
                result = float(x.replace(',','').replace(';','').split('$')[-1].strip().split(' ')[0])
        else:
            result = float(x.replace(',','').split('$')[1].strip().split(' ')[0])
    else: result = None
    print('Convert ', x, ' to ', result)
    return result

p_df['Price'] = p_df['Price'].apply(lambda x:clean_price(x))

# changing the format of the price
p_df.loc[p_df['Currency']=='BR',['Price']] = p_df.loc[p_df['Currency']=='BR',['Price']] /100.0
p_df.loc[p_df['Currency']=='CL',['Price']] = p_df.loc[p_df['Currency']=='CL',['Price']]*1000

p_df = p_df.assign(Date=todayDate)

p_df = p_df.rename(columns={'Date':'DATE','Platform':'PLATFORM','Country':'COUNTRY','Price':'PRICE','Currency':'CURRENCY'})


# debug
print(p_df)

write_pandas(ctx, p_df, 'AC_PRICE_TRACKING_API_MS')