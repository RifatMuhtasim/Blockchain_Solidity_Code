from brownie import network, accounts
from web3 import Web3
import os


Forked_blockchain = ["mainnet-fork", "mainnet-fork-dev"]
Local_blockchain = ["development", "ganache-local"]

def get_account():
     if (network.show_active() in Local_blockchain or network.show_active() in Forked_blockchain):
          return accounts[0]
     else:
          return accounts.add(os.getenv("PRIVATE_KEY"))