exports.handler = async () => {
    const base = process.env.ALPACA_BASE_URL || 'https://paper-api.alpaca.markets/v2';
    const res = await fetch(`${base}/account`, {
        headers: {
            'APCA-API-KEY-ID': process.env.ALPACA_KEY_ID,
            'APCA-API-SECRET-KEY': process.env.ALPACA_SECRET,
        },
    });

    const text = await res.text();
    return {
        statusCode: res.status,
        headers: { 'content-type': res.headers.get('content-type') || 'application/json' },
        body: text,
    };
};
