
// メッセージのsenderのItemIdを格納する変数を用意する
let itemId = null;


//アクセサリプロダクトIDを格納する変数を用意する
let foo = _.getAccessoryProductIds();
if (foo.includes("b096b7cf-24d9-46d2-ad3b-8e7c331c7e86")) {
    let weaponBaseDamage = 5;
    _.log("inko");
}


// PlayerScriptがメッセージを受け取ったときのコールバックを登録する
_.onReceive((messageType, arg, sender) => {
    switch (messageType) {
        case "send":
            if (sender instanceof ItemId) {
                // Itemから"send"メッセージを受け取ったらlogを表示する
                _.log("Received from ItemId: " + sender.id);
                // グローバル変数のitemIdにsenderを代入する
                itemId = sender;
            }
            break;
    }
});

// PlayerScriptで毎フレーム呼ばれるコールバックを登録する
_.onFrame((deltaTime) => {
    if (itemId !== null) {
        // itemIdがnullでない場合、itemIdに"hello"メッセージを送ってitemIdをnullにする
        _.sendTo(itemId, "hello",weaponBaseDamage);
        itemId = null;
    }
});