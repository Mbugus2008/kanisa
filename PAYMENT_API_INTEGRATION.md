# Payment API Integration Guide

## API Endpoint
```
POST http://trimline.co.ke:4006/api/pushstk
```

## Single Payment Request

### Request Format
```json
{
  "Mobile": "0710563359",
  "Amount": 10.0,
  "CustomerNo": "C001",
  "VoteHeadCode": "TITHE",
  "VoteHeadName": "Tithe",
  "Description": "Tithe payment - John Doe",
  "Reference": "KNS1698765432100"
}
```

### Response Format
```json
{
  "Code": 0,
  "Desc": "Successful",
  "Contents": {
    "success": true,
    "MerchantRequestID": "5df4-4b66-901c-ce740da6448e7081965",
    "CheckoutRequestID": "ws_CO_01112025131231508710563359",
    "ResponseCode": "0",
    "ResponseDescription": "Success. Request accepted for processing",
    "CustomerMessage": "Success. Request accepted for processing"
  }
}
```

## Multiple Payments Request

### Request Format
```json
{
  "Mobile": "0710563359",
  "Amount": 2000.0,
  "CustomerNo": "C001",
  "PaymentItems": [
    {
      "VoteHeadCode": "MEMBERSHIP",
      "VoteHeadName": "Church Membership",
      "Amount": 500.0
    },
    {
      "VoteHeadCode": "TITHE",
      "VoteHeadName": "Tithe",
      "Amount": 1200.0
    },
    {
      "VoteHeadCode": "FELLOWSHIP",
      "VoteHeadName": "Fellowship Contribution",
      "Amount": 300.0
    }
  ],
  "Description": "Multiple payments: Church Membership, Tithe, Fellowship - John Doe",
  "Reference": "KNS1698765432200"
}
```

### Response Format
Same as single payment response above.

## Phone Number Format
- Mobile numbers should be in Kenyan format
- Examples: `0710563359`, `0712345678`
- The app automatically formats numbers starting with `0` to `254` format internally for M-Pesa

## Response Handling

### Success Indicators
- `Code`: 0
- `Contents.success`: true
- `Contents.ResponseCode`: "0"

### CheckoutRequestID
Used for tracking payment status:
- Format: `ws_CO_01112025131231508710563359`
- Store this to check payment completion status

## Payment Status Check
**Note:** You need to provide the endpoint for checking payment status using CheckoutRequestID.

Suggested endpoint:
```
GET/POST /api/payment-status?checkoutRequestId={CheckoutRequestID}
```

Expected response format for status check:
```json
{
  "Code": 0,
  "Desc": "Successful",
  "Contents": {
    "customerNo": "C001",
    "customerName": "John Doe",
    "voteHeadCode": "TITHE",
    "voteHeadName": "Tithe",
    "amount": 10.0,
    "status": "completed",
    "paymentMethod": "mpesa",
    "mpesaReceiptNumber": "QGH7X8Y9Z0",
    "mpesaTransactionId": "ws_CO_01112025131231508710563359",
    "phoneNumber": "254710563359",
    "paymentDate": "2025-11-01T13:12:45Z"
  }
}
```

## Vote Heads (Payment Types)

### Predefined Vote Heads
1. **MEMBERSHIP** - Church Membership (Fixed: KES 500)
2. **GROUP_MEMBERSHIP** - Group Membership (Fixed: KES 200)
3. **TITHE** - Tithe (Custom amount)
4. **OFFERING** - Offering (Custom amount)
5. **FELLOWSHIP** - Fellowship Contribution (Custom: KES 300)
6. **BUILDING_FUND** - Building Fund (Custom: KES 500)
7. **MISSIONS** - Missions Support (Custom: KES 200)

### Vote Head Properties
- `code`: Unique identifier
- `name`: Display name
- `description`: Description for members
- `defaultAmount`: Suggested amount
- `allowCustomAmount`: Whether amount can be changed
- `isActive`: Whether currently available
- `category`: Registration, Contribution, Fellowship, Special

## Error Handling

### Network Errors
```json
{
  "Code": 1,
  "Desc": "Network error occurred",
  "Contents": null
}
```

### Validation Errors
```json
{
  "Code": 2,
  "Desc": "Invalid mobile number format",
  "Contents": null
}
```

### M-Pesa Errors
```json
{
  "Code": 0,
  "Desc": "Successful",
  "Contents": {
    "success": false,
    "ResponseCode": "1",
    "ResponseDescription": "The initiator information is invalid",
    "CustomerMessage": "Unable to process payment"
  }
}
```

## Implementation Notes

1. **Single vs Multiple Payments**: Both use the same `/pushstk` endpoint
2. **Amount Field**: Always called `Amount` (not `TotalAmount` for multiple)
3. **Capital Case**: All field names use PascalCase (Capital first letter)
4. **Optional Fields**: CustomerNo, Description, Reference are optional but recommended
5. **Logging**: All payment operations are logged for debugging

## Flutter App Flow

1. **Member selects payment types** (checkboxes for multiple selection)
2. **Enters/confirms amounts** (inline for each selected item)
3. **Reviews payment summary** (itemized list with total)
4. **Taps "Pay with M-Pesa"** button
5. **App sends request** to `/pushstk`
6. **Backend returns** CheckoutRequestID
7. **Member receives** M-Pesa prompt on phone
8. **Member enters** M-Pesa PIN
9. **App polls** payment status (needs status endpoint)
10. **Shows confirmation** with receipt number

## Testing

### Test Single Payment
```bash
curl -X POST http://trimline.co.ke:4006/api/pushstk \
  -H "Content-Type: application/json" \
  -H "X-Client-Identifier: kirigiti" \
  -d '{
    "Mobile": "0710563359",
    "Amount": 10.0,
    "VoteHeadCode": "TITHE",
    "VoteHeadName": "Tithe"
  }'
```

### Test Multiple Payments
```bash
curl -X POST http://trimline.co.ke:4006/api/pushstk \
  -H "Content-Type: application/json" \
  -H "X-Client-Identifier: kirigiti" \
  -d '{
    "Mobile": "0710563359",
    "Amount": 800.0,
    "PaymentItems": [
      {"VoteHeadCode": "MEMBERSHIP", "VoteHeadName": "Church Membership", "Amount": 500.0},
      {"VoteHeadCode": "FELLOWSHIP", "VoteHeadName": "Fellowship", "Amount": 300.0}
    ]
  }'
```

## Security Considerations

1. Always use HTTPS in production
2. Validate mobile numbers on backend
3. Implement rate limiting for payment requests
4. Store CheckoutRequestID for audit trail
5. Log all payment transactions
6. Implement timeout for pending payments (5 minutes recommended)

## Next Steps

1. ✅ Frontend implementation complete
2. ⏳ Provide payment status check endpoint
3. ⏳ Provide payment history endpoint (optional - can use existing `/payments/history`)
4. ⏳ Test with actual M-Pesa sandbox/production
5. ⏳ Implement webhook for payment notifications (recommended)
