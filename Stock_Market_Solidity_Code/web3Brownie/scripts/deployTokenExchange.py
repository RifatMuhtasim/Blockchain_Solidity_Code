from brownie import TokenExchangeContract
from scripts.helpful_script import get_account


def DeployTokenExchangeContract():
     print("Deploying Contract on Blockchain ...")
     account = get_account()
     TokenExchange = TokenExchangeContract.deploy({"from": account})
     print(f"Token Exchange Contract Deployed on {TokenExchange.address}")


def main():
     DeployTokenExchangeContract()