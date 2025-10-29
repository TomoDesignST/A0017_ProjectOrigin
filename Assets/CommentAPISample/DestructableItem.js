$.onReceive((messageType, arg, sender) => {
    if (messageType === "Destroy") {
        $.destroy();
    }
});