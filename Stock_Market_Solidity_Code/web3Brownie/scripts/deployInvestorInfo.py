from brownie import InvestorInformation
from scripts.helpful_script import get_account


def DeployInvestorInformationOnBlockchain():
     print("Deploying Contract on Blockchain ...")
     account = get_account()
     InvestorInfo = InvestorInformation.deploy( {"from": account})
     print(f"Investor's Information deployed on {InvestorInfo.address}")


def main():
     DeployInvestorInformationOnBlockchain()