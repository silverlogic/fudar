#  Clover API Help

## Creating an Order

You'll need to know your merchantID.

### getting items

You need to get the list of items for your merchant.
We're going to use a particular tag to have more control over what items show up.

GET https://api.clover.com/v3/merchants/{MID}/tags/{tagID}/items

Example response:

```
{
"elements": [
{
"id": "4XWS84QQWPFKW",
"hidden": false,
"name": "Southwestern Thai Fusion Banana ",
"alternateName": "TexMexThaiBro",
"price": 1200,
"priceType": "FIXED",
"defaultTaxRates": true,
"cost": 500,
"isRevenue": true,
"stockCount": 0,
"modifiedTime": 1508638707000
},
...
}
```

### Create an empty order!

```
POST https://api.clover.com/v3/merchants/{MID}/orders
```

you'll get back the id for your order

```
{
"href": "https://www.clover.com/v3/merchants/{MID}/orders/PJAK15WXF2YHY",
"id": "PJAK15WXF2YHY",
"currency": "USD",
...
}
```

### Add 1 line items to your order (you can repeat this)

```
POST https://api.clover.com/v3/merchants/{MID}/orders/K5KTNGPQR1ZK4/line_items
```

body

```
{
"item": {"id":"2HDH3QRPEN29W"}
}
```

response:

```
{
"id": "VDHD7HNNZNPQE",
"orderRef": {
"id": "K5KTNGPQR1ZK4"
},
"item": {
"id": "2HDH3QRPEN29W"
},
"name": "Black Label",
"alternateName": "",
"price": 2100,
"itemCode": "200092121007",
"printed": false,
"createdTime": 1508640186000,
"orderClientCreatedTime": 1508638395000,
"exchanged": false,
"refunded": false,
"isRevenue": true
}
```


