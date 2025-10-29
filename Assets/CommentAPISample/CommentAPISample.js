const targetItem = new WorldItemTemplateId("targetItem"); // WorldItemTemplateListで指定した生成するアイテム

// 設定を変えたいときはここを変更
const maxItemCount = 10; // 生成するアイテムの最大数（超えた場合は古い方から消す）※1以上にしてください
const keyword = "create"; // createを実行するキーワード
const requiresStrictMatch = true; // trueのときはコメントとkeywordが完全一致、falseのときはコメント中にkeywordが含まれていたらcreateする

$.onStart(() => {
    $.state.createdItems = []; // 生成したアイテム
    $.state.lastTimestamp = 0; // 最後に取得したコメントのタイムスタンプ
});

$.onCommentReceived((comments) => {
    if (maxItemCount <= 0) {
        return;
    }

    const createdItems = $.state.createdItems;
    let lastTimestamp = $.state.lastTimestamp;

    let createCount = 0;
    comments.forEach(comment => {
        const commentBody = comment.body; // コメントの本文
        const commentTimestamp = comment.timestamp; // コメントのタイムスタンプ

        // 何らかの要因で古いコメントが読み込まれてしまった場合は無視する
        if (commentTimestamp <= lastTimestamp) {
            return;
        }

        // 特定の内容のコメントの数だけアイテムを生成する
        if (hasKeyword(commentBody)) {
            createCount++;
        }

        lastTimestamp = Math.max(lastTimestamp, commentTimestamp);
    });

    createCount = Math.min(createCount, maxItemCount);

    // 生成できるアイテムの残りが生成したい数に足りない場合は、生成済みのアイテムに対して古い方から"Destroy"メッセージを送信
    // メッセージを受け取った側でdestroy処理を実行するようにしておく
    while (maxItemCount - createdItems.length < createCount) {
        const item = createdItems.shift();
        item.send("Destroy", 0);
    }

    for (let i = 0; i < createCount; i++) {
        try {
            const createdItem = $.createItem(targetItem, $.getPosition(), $.getRotation());
            createdItems.push(createdItem);
        }
        catch (e) {
            $.log("createItemに失敗しました");
        }
    }

    $.state.createdItems = createdItems;
    $.state.lastTimestamp = lastTimestamp;
});

function hasKeyword(text) {
    if (requiresStrictMatch) {
        return text === keyword;
    }
    else {
        return text.includes(keyword);
    }
}
