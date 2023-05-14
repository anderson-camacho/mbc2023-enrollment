import TrieMap "mo:base/TrieMap";
import Trie "mo:base/Trie";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Principal "mo:base/Principal";
import Account "Account";
import RemoteCanisterActor "RemoteCanisterActor";

actor class MotoCoin() {

  public type Account = Account.Account;

  stable var coinData = {
    name : Text = "MotoCoin";
    symbol : Text = "MOC";
    var supply : Nat = 0;
  };
  var ledger = TrieMap.TrieMap<Account, Nat>(Account.accountsEqual, Account.accountsHash);

  public query func name() : async Text {
    return coinData.name;
  };

  public query func symbol() : async Text {
    return coinData.symbol;
  };

  public func totalSupply() : async Nat {
    return coinData.supply;
  };

  public query func balanceOf(account : Account) : async (Nat) {
    let accountUser : ?Nat = ledger.get(account);
    switch (accountUser) {
      case (null) { return 0 };
      case (?account) {
        return account;
      };
    };
  };

  public shared ({ caller }) func transfer(from : Account, to : Account, amount : Nat) : async Result.Result<(), Text> {
    let accountNull : ?Nat = ledger.get(from);
    switch (accountNull) {
      case (null) {
        return #err("Your " # coinData.name # " Insufficient balance.");
      };
      case (?accountBalanceNull) {
        if (accountBalanceNull < amount) {
          return #err("Your " # coinData.name # "Insufficient balance.");
        };
        ignore ledger.replace(from, accountBalanceNull - amount);
        let accountNullTarget : ?Nat = ledger.get(to);
        switch (accountNullTarget) {
          case (null) {
            ledger.put(to, amount);
            return #ok();
          };
          case (?accountNullBalanceTarget) {
            ignore ledger.replace(to, accountNullBalanceTarget + amount);
            return #ok();
          };
        };
      };
    };
  };

  private func addBalance(wallet : Account, amount : Nat) : async () {
    let accountNull : ?Nat = ledger.get(wallet);
    switch (accountNull) {
      case (null) {
        ledger.put(wallet, amount);
        return ();
      };
      case (?accountBalanceNull) {
        ignore ledger.replace(wallet, accountBalanceNull + amount);
        return ();
      };
    };
  };

  public func airdrop() : async Result.Result<(), Text> {
    try {
      var students : [Principal] = await RemoteCanisterActor.RemoteActor.getAllStudentsPrincipal();
      for (student in students.vals()) {
        var studentAccount = { owner = student; subaccount = null };
        await addBalance(studentAccount, 100);
        coinData.supply += 100;
      };
      return #ok();
    } catch (e) {
      return #err "Something went wrong!";
    };
  };
};
