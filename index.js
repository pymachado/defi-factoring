const Web3 = require("web3");
const Wallet = require("./build/contracts/Wallet.json");
const web3 = new Web3("http://127.0.0.1:9545/");
const { default: BigNumber } = require("bignumber.js");

const factor = "0x1909be1c1c06ccde5b35ec0de613f15657ebc7d9";
const buyer = "0x5846346ebbf4b6e2d74a61b846666e605afd0d2d";
const nonceInvoice = 1;
const amount = BigNumber(1000000000000000000); 
const reserve = BigNumber(200000000000000000);
const factoringFee = BigNumber(20000000000000000);
const feePerDay = BigNumber(5000000000000000);
const dayMaxOfSaleInvoice = 30;
const daysOutstandingFactoring = 20;


async function admin () {
    const id = await web3.eth.net.getId();
    const deployedNetwork = Wallet.networks[id];
    const contract = new web3.eth.Contract(Wallet.abi, deployedNetwork.address);
    const addresses = await web3.eth.getAccounts();
    const transaction = await contract.methods.admin().call({from: addresses[0]});    
    console.log(transaction);
}

async function getNumberOfTokens() {
    const id = await web3.eth.net.getId();
    const deployedNetwork = Wallet.networks[id];
    const contract = new web3.eth.Contract(Wallet.abi, deployedNetwork.address);
    const addresses = await web3.eth.getAccounts();
    const transaction = await contract.methods.getNumberOfTokens().call({from: addresses[0]});    
    console.log(transaction);
}

async function uploadDeal() {
    const id = await web3.eth.net.getId();
    const deployedNetwork = Wallet.networks[id];
    const contract = new web3.eth.Contract(Wallet.abi, deployedNetwork.address);
    const addresses = await web3.eth.getAccounts();
    const transaction = await contract.methods.uploadDeal(addresses[1], factor, buyer, nonceInvoice, amount, reserve, 
        dayMaxOfSaleInvoice, daysOutstandingFactoring, factoringFee, feePerDay).send({
            from: addresses[1]
        });
    console.log(transaction);
}

//getNumberOfTokens();
uploadDeal();