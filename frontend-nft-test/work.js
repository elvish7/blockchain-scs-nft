const ABI = "./abi.json";
const ADDRESS = "0x0Dbd3d218877ce1d682fEA7ef1ddD08f2bD64346";

var account = null;
var contract = null;

(async () => {
    if (window.ethereum) {
        await window.ethereum.send('eth_requestAccounts');
        window.web3 = new Web3(window.ethereum);

        var accounts = await web3.eth.getAccounts();
        account = await accounts[0];
        document.getElementById('wallet-address').textContent = account;

        contract = new web3.eth.Contract(await $.get(ABI), ADDRESS);

        document.getElementById('mint').onclick = () => {
            var tokenId = Number(document.querySelector("[name=tokenId]").value);
            var amount = Number(document.querySelector("[name=amount]").value);
            contract.methods.mint(account, tokenId, amount).send({ from: account, 
                                                                    gas: 4700000, value: 50000000000000000});
        }
    }
})();