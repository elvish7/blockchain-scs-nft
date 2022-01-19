const ABI = "./abi.json";
const ADDRESS = "0x3509560B4471E3fFE7158A33a405A8Ea6b32376C";

var account = null;
var contract = null;

(async () => {
    if (window.ethereum) {
        await window.ethereum.send('eth_requestAccounts');
        window.web3 = new Web3(window.ethereum);

        var accounts = await web3.eth.getAccounts();
        account = await accounts[0];
        contract = new web3.eth.Contract(await $.get(ABI), ADDRESS);
    }
})();

// Register
document.getElementById('register').onclick = () => {
    var cName = String(document.querySelector("[name=cName]").value);
    var date = String(document.querySelector("[name=date]").value).split('-').join('');
    var amount = Number(document.querySelector("[name=amount]").value);
    var keys = Array(document.querySelector("[name=keys]").value);
    contract.methods.register(cName, date, amount, keys).send({ from: account, gas: 4700000}) //value: 50000000000000000
                                                        .catch((error) => {
                                                            alert(error['message'])}); 
}

// Search company's info
document.getElementById('search-button').onclick = () => {
    var search_cName = String(document.querySelector("[name=search]").value);
    contract.methods.lookup(search_cName).call()
                    .then(function( info ) { 
                        document.getElementById('results').style.display="block";
                        document.getElementById('noC').style.display = "none";
                        document.getElementById('getcName').textContent = info[0];
                        document.getElementById('getfDate').textContent = info[1];
                        document.getElementById('getoshare').textContent = info[2];
                        document.getElementById('getcertificates').textContent = info[3];
                    })
                    .catch((error) => {
                        document.getElementById('noC').style.display = "block";
                        document.getElementById('results').style.display="none";
                    });
}
