# 🎯 ZabGo Seat Request + Approval System

## Overview
The ZabGo app has been enhanced with a seat request and approval flow, replacing the direct booking system. This provides better control for ride owners and a more secure booking experience.

## 🚀 Key Features

### For Passengers:
- **Seat Selection**: Select one or more available seats
- **Request with Message**: Send optional message to driver
- **Real-time Updates**: See seat availability changes instantly
- **Gender-coded Seats**: Visual indication of seat occupancy by gender

### For Drivers (Ride Owners):
- **Request Management**: View all incoming seat requests
- **Approval Control**: Accept or reject requests with confirmation
- **Passenger Info**: See passenger details (name, department, year)
- **Real-time Notifications**: Get notified of new requests instantly

## 🏗️ Technical Implementation

### Database Schema
```sql
-- ride_requests table
CREATE TABLE ride_requests (
    id UUID PRIMARY KEY,
    ride_id UUID REFERENCES rides(id),
    seat_numbers TEXT[], -- Array of requested seat numbers
    requested_by UUID REFERENCES users(id),
    status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
    message TEXT, -- Optional message from passenger
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Updated rides.seats structure
{
  "1": {"isBooked": false, "bookedBy": null, "gender": null},
  "2": {"isBooked": true, "bookedBy": "user_id", "gender": "male"},
  "3": {"isBooked": false, "bookedBy": null, "gender": null}
}
```

### Controllers Updated
1. **RideRequestController**: Handles sending requests, accepting/rejecting, real-time updates
2. **RideDetailController**: Modified for seat requests instead of direct booking
3. **SearchRideController**: Enhanced with real-time seat status updates

### New Screens
1. **RideRequestsScreen**: Driver interface to manage incoming requests

### Updated Screens
1. **RideDetailScreen**: New UI for seat request flow with message input
2. **SearchRideScreen**: Shows "Manage Requests" button for ride owners

## 🎨 UI/UX Features

### Seat Color Coding
- **Grey**: Available seats
- **Green**: Currently selected by user
- **Blue**: Booked by male passenger
- **Pink**: Booked by female passenger
- **Red**: Booked (gender unspecified)

### Real-time Updates
- Seat availability updates instantly across all users
- Request status changes reflected immediately
- New request notifications for drivers

## 🔄 User Flow

### Passenger Journey:
1. Browse available rides in SearchRideScreen
2. Select a ride and view RideDetailScreen
3. Select desired seats
4. Add optional message
5. Send seat request
6. Wait for driver approval
7. Receive real-time status updates

### Driver Journey:
1. Post ride using OfferRideScreen
2. View ride in SearchRideScreen with "Manage Requests" button
3. Click "Manage Requests" to open RideRequestsScreen
4. Review passenger details and seat requests
5. Accept or reject requests
6. Real-time seat booking updates

## 🔒 Security Features

### Row Level Security (RLS)
- Users can only view their own requests + requests for their rides
- Only ride owners can accept/reject requests
- Users can only request seats for active rides (not their own)

### Data Validation
- Prevents duplicate requests from same user
- Validates seat availability before acceptance
- Checks ride ownership for request management

## 📱 Navigation Structure

```
SearchRideScreen
├── RideDetailScreen (for passengers)
└── RideRequestsScreen (for drivers via "Manage Requests")

RideDetailScreen
├── Seat selection UI
├── Message input
└── Send Request button (passengers only)
```

## 🛠️ Setup Instructions

1. **Run Supabase Schema**: Execute the SQL in `supabase_schema.sql` in your Supabase dashboard
2. **Update Dependencies**: All required packages are already in `pubspec.yaml`
3. **Real-time Setup**: Ensure Supabase real-time is enabled for `rides` and `ride_requests` tables

## 🧪 Testing Checklist

- [ ] Passenger can select seats and send requests
- [ ] Driver receives real-time request notifications
- [ ] Seat colors update based on gender and availability
- [ ] Accept/reject flow works properly
- [ ] Prevents duplicate requests
- [ ] Real-time seat updates across multiple users
- [ ] Ride owner can't request their own rides
- [ ] Proper error handling for edge cases

## 🚀 Future Enhancements

- Push notifications for request status changes
- Advanced filtering (gender preferences, etc.)
- Request expiration after certain time
- Bulk accept/reject for drivers
- Request history and statistics