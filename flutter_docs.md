# Flutter App API Integration Guide

This document provides instructions and API documentation for the Flutter Rider and Driver applications.

**Base URL:** `https://your-api-domain.com` (e.g., `https://buco-ride-payment-system.vercel.app`)

---

## Table of Contents
1.  General Authentication Flow
2.  Rider App Integration
    *   Rider Authentication
    *   Requesting a Trip
    *   Real-time Trip Updates (Rider)
3.  Driver App Integration
    *   Driver Authentication
    *   Vehicle Management
    *   Real-time Location Updates (Driver)
    *   Managing Trips (Driver)

---

## 1. General Authentication Flow

Both apps use a two-step authentication process that combines Firebase Authentication for user verification and a custom backend JWT for session management.

1.  **Firebase Authentication:** Use the Firebase Authentication SDK in your Flutter app to sign up or log in a user (e.g., with phone number, email/password).
2.  **Get Firebase ID Token:** After a successful Firebase login, get the user's ID token.
3.  **Backend Login:** Send this Firebase ID token to our backend's `/login` endpoint.
4.  **Receive Custom JWT:** The backend will verify the Firebase token, find the user in its own database, and return a custom JSON Web Token (JWT).
5.  **Store JWT:** Securely store this JWT in the app's local storage (e.g., using `flutter_secure_storage`).
6.  **Authenticated Requests:** For all subsequent API requests to our backend, include this JWT in the `Authorization` header.

    ```
    Authorization: Bearer <your_jwt_access_token>
    ```

---

## 2. Rider App Integration

### Rider Authentication

#### Register a New Rider

*   **Endpoint:** `POST /api/riders/register`
*   **Description:** Creates a new rider profile in our database after they have successfully signed up with Firebase.
*   **Request Body:**
    ```json
    {
        "uid": "firebase_user_id_string",
        "name": "John Doe",
        "phone": "254712345678",
        "email": "john.doe@example.com"
    }
    ```
*   **Success Response (201 Created):**
    ```json
    {
        "success": true,
        "message": "Rider registered successfully.",
        "rider": {
            "id": 1,
            "name": "John Doe",
            "email": "john.doe@example.com"
        }
    }
    ```

#### Log In a Rider

*   **Endpoint:** `POST /api/riders/login`
*   **Description:** Verifies a rider's Firebase token and returns a custom JWT and their profile.
*   **Headers:** `Authorization: Bearer <firebase_id_token>`
*   **Request Body (Optional but Recommended):**
    ```json
    {
        "fcmToken": "the_device_fcm_registration_token"
    }
    ```
*   **Success Response (200 OK):**
    ```json
    {
        "success": true,
        "message": "Login successful.",
        "accessToken": "your_custom_backend_jwt",
        "rider": {
            "id": 1,
            "user_id": "firebase_user_id_string",
            "name": "John Doe",
            "email": "john.doe@example.com",
            "phone": "254712345678",
            "status": "active"
        }
    }
    ```

### Requesting a Trip

*   **Endpoint:** `POST /api/trips/request`
*   **Authentication:** Custom JWT required.
*   **Description:** A rider requests a new ride or parcel delivery.
*   **Request Body:**
    ```json
    {
        "tripType": "ride", // or "parcel"
        "pickup": {
            "address": "123 ABC Street, Nairobi",
            "lat": -1.286389,
            "lng": 36.817223
        },
        "dropoff": {
            "address": "456 XYZ Avenue, Nairobi",
            "lat": -1.292066,
            "lng": 36.821945
        },
        // Include this object ONLY if tripType is "parcel"
        "parcelDetails": {
            "recipientName": "Jane Smith",
            "recipientPhone": "254798765432",
            "description": "A small box of documents",
            "size": "small"
        }
    }
    ```
*   **Success Response (201 Created):**
    ```json
    {
        "success": true,
        "message": "Trip requested successfully.",
        "trip": {
            "id": 123, // The new trip ID
            "status": "requested",
            "estimated_fare": "250.00"
        }
    }
    ```

#### Cancel a Trip (Rider)

*   **Endpoint:** `PUT /api/trips/:tripId/cancel`
*   **Authentication:** Custom JWT required (Rider).
*   **Description:** A rider cancels a trip they have requested. This can be done before or after a driver has accepted.
*   **URL Parameter:**
    *   `:tripId` (integer): The ID of the trip to cancel.
*   **Request Body:** None.
*   **Success Response (200 OK):**
    ```json
    {
        "success": true,
        "message": "Trip has been successfully cancelled."
    }
    ```
*   **Error Response (400 Bad Request):**
    If the trip is already completed or cancelled.
    ```json
    {
        "error": "Cannot cancel a trip that is already completed."
    }
    ```

#### Rate a Completed Trip

*   **Endpoint:** `POST /api/trips/:tripId/rate`
*   **Authentication:** Custom JWT required (Rider).
*   **Description:** Allows a rider to submit a rating and an optional comment for a driver after a trip is completed. A trip can only be rated once.
*   **URL Parameter:**
    *   `:tripId` (integer): The ID of the completed trip.
*   **Request Body:**
    ```json
    {
        "rating": 5,
        "comment": "The driver was very professional and the car was clean."
    }
    ```
    *   `rating` (integer, required): A rating from 1 to 5.
    *   `comment` (string, optional): A text comment.
*   **Success Response (201 Created):**
    ```json
    {
        "success": true,
        "message": "Thank you for your feedback!",
        "newAverageRating": "4.85"
    }
    ```
*   **Error Response (409 Conflict):**
    If the trip has already been rated.
    ```json
    {
        "error": "This trip has already been rated."
    }
    ```

### Making a Payment

Once a trip is completed, the rider can pay for it using Mpesa.

#### Initiate Mpesa STK Push

*   **Endpoint:** `POST /api/payments/mpesa/stk-push`
*   **Authentication:** Custom JWT required (Rider).
*   **Description:** Initiates an Mpesa STK Push to the rider's phone to pay for a completed trip. The backend will use the `actual_fare` from the trip to determine the amount.
*   **Request Body:**
    ```json
    {
        "tripId": 123,
        "phone": "254712345678"
    }
    ```
    *   `tripId` (integer): The ID of the trip to be paid for.
    *   `phone` (string): The Mpesa-registered phone number to receive the payment prompt.
*   **Success Response (200 OK):**
    Indicates that the STK push has been successfully initiated. The actual payment confirmation will be handled by the backend via a callback from Mpesa.
    ```json
    {
        "success": true,
        "message": "STK push initiated. Please check your phone to complete the payment.",
        "checkoutRequestID": "ws_CO_..."
    }
    ```
*   **Error Response (404 Not Found):**
    ```json
    {
        "error": "Trip not found or has no outstanding balance."
    }
    ```

#### Payment Status Notifications

After initiating an STK push, the rider will receive push notifications for payment outcomes:

*   **Payment Success Notification:**
    *   **Title:** "Payment Received"
    *   **Body:** `Thank you! Your payment of KES {amount} for trip #{tripId} was successful.`
    *   **Data:** `{ "type": "TRIP_PAYMENT_SUCCESS", "tripId": "123" }`

*   **Payment Cancelled Notification:**
    *   **Title:** "Payment Cancelled"
    *   **Body:** "You cancelled the payment for this trip. Please try again when ready."
    *   **Data:** `{ "type": "TRIP_PAYMENT_FAILED", "tripId": "123", "resultCode": 1032 }`

*   **Payment Failed Notification:**
    *   **Title:** "Payment Failed"
    *   **Body:** `Trip payment failed: {error_description}`
    *   **Data:** `{ "type": "TRIP_PAYMENT_FAILED", "tripId": "123", "resultCode": "{result_code}" }`

### Real-time Trip Updates (Rider)

*   **Method:** Use the **Firestore SDK** to listen for changes on a specific trip document.
*   **Path:** `trips/{tripId}` (where `tripId` is the ID received from the `/api/trips/request` response).
*   **Action:** After requesting a trip, subscribe to real-time updates on this document. The document will be updated by the backend whenever a driver accepts the trip or changes its status. This allows you to show the rider "Driver accepted," "Driver is arriving," etc.
*   **Data Structure:** The document will contain the following key fields:
    *   `status` (string): The current state of the trip. The app UI should react to changes in this value.
    *   `driver` (object): This object will be **added** to the document when a driver accepts the trip. It will be **removed** if the driver cancels.

#### Possible Trip Statuses

Your app should be prepared to handle the following statuses from the Firestore document:

*   `requested`: The initial state. The app should show a "Searching for drivers..." UI.
*   `accepted`: A driver has accepted. The `driver` object is now available. The app should display the driver's details and their location on the map.
*   `en_route_to_pickup`: Driver is on their way to the rider.
*   `arrived_at_pickup`: Driver has arrived at the pickup location.
*   `in_progress`: The trip has started.
*   `completed`: The trip is finished. The app should prompt for payment.
*   `cancelled_by_driver`: The assigned driver cancelled. The `driver` object will be removed, and the status will revert to `requested` as the system searches for a new driver. The app should notify the user and return to the "Searching..." state.
*   `cancelled_by_rider`: The rider cancelled the trip. The app should close the trip screen.
*   `no_drivers_found`: The system could not find any available drivers within the timeout period (e.g., 3-5 minutes). The app should inform the user and allow them to try again.

#### Driver Object Example

When `status` is `accepted` (or any subsequent state before completion/cancellation), the `driver` object will look like this:

```json
{
    "id": 5,
    "uid": "firebase_user_id_string",
    "name": "Driver Dan",
    "rating": 4.8,
    "profilePhotoUrl": "https://storage.googleapis.com/...",
    "vehicle": {
        "model": "Toyota Vitz",
        "color": "Silver",
        "numberPlate": "KDA 123B"
    }
}
```

#### Push Notifications for Trip Events

In addition to Firestore updates, the rider will receive push notifications for key events:

*   **Driver Found:**
    *   **Title:** "Driver Found!"
    *   **Body:** `Driver Dan is on the way in a Silver Toyota Vitz.`
    *   **Data:** `{ "type": "DRIVER_ACCEPTED", "tripId": "123", ...driverDetails }`
*   **Driver Cancelled:**
    *   **Title:** "Driver Cancelled"
    *   **Body:** "Your driver has cancelled. We are finding you a new driver now."
    *   **Data:** `{ "type": "DRIVER_CANCELLED", "tripId": "123" }`
*   **No Drivers Found:**
    *   **Title:** "No Drivers Found"
    *   **Body:** "We could not find a driver for your request at this time. Please try again later."
    *   **Data:** `{ "type": "NO_DRIVERS_FOUND", "tripId": "123" }`

---

## 3. Driver App Integration

### Driver Authentication

#### Register a New Driver

*   **Endpoint:** `POST /api/auth/register`
*   **Description:** Creates a new driver profile.
*   **Request Body:**
    ```json
    {
        "uid": "firebase_user_id_string",
        "name": "Driver Dan",
        "phone": "254711223344",
        "email": "dan.driver@example.com"
    }
    ```

#### Log In a Driver

*   **Endpoint:** `POST /api/auth/login`
*   **Description:** Verifies a driver's Firebase token and returns a custom JWT and their profile.
*   **Headers:** `Authorization: Bearer <firebase_id_token>`
*   **Request Body (Optional but Recommended):**
    ```json
    {
        "fcmToken": "the_device_fcm_registration_token"
    }
    ```
*   **Success Response (200 OK):**
    ```json
    {
        "success": true,
        "message": "Login successful.",
        "accessToken": "your_custom_backend_jwt",
        "driver": {
            "id": 1,
            "user_id": "firebase_user_id_string",
            "name": "Driver Dan"
        },
        "vehicle": {
            "id": 1,
            "brand": "Toyota",
            "model": "Vitz",
            "vehicleType": "Sedan",
            "year": 2018,
            "licensePlate": "KDA 123B",
            "isSubscriptionActive": true,
            "subscriptionExpiresAt": "2025-12-29T12:00:00.000Z"
        }
    }
    ```

### Vehicle Management

#### Register/Update Vehicle Details

*   **Endpoint:** `POST /api/vehicles/register`
*   **Authentication:** Custom JWT required.
*   **Description:** Saves the driver's vehicle information. This can be called multiple times to update details.
*   **Request Body:**
    ```json
    {
        "brand": "Toyota",
        "model": "Vitz",
        "year": 2018,
        "licensePlate": "KDA 123B",
        "color": "Silver",
        "fuelType": "Petrol",
        "vehicleType": "Sedan"
    }
    ```

#### Upload Vehicle Documents

*   **Endpoint:** `POST /api/vehicles/upload-document`
*   **Authentication:** Custom JWT required.
*   **Description:** Uploads a single document file. This is a `multipart/form-data` request.
*   **Form Data:**
    *   `docType` (text): The type of document. Must be one of `logbook`, `insurance`, or `vehicleFront`.
        *   **Valid Values:**
            *   `logbook`
            *   `insurance`
            *   `vehicleFront`
            *   `psvLicense`
            *   `goodConductCertificate`
            *   `selfie`
            *   `inspectionReport`
            *   `psvSticker`
            *   `vehicleRear`
            *   `vehicleSide`
            *   `vehicleInterior`
    *   `document` (file): The image or PDF file to upload.
*   **Success Response (200 OK):**
    ```json
    {
        "success": true,
        "message": "logbook uploaded successfully.",
        "url": "https://storage.googleapis.com/..."
    }
    ```

### Driver Payments

#### Vehicle Registration Payment

*   **Endpoint:** `POST /api/payments/mpesa/vehicle-registration`
*   **Authentication:** Custom JWT required (Driver).
*   **Description:** Initiates an Mpesa STK Push to the driver's phone to pay for the vehicle registration fee. The backend determines the amount based on the vehicle type (e.g., KES 249 for a motorbike, KES 549 for other vehicles).
*   **Request Body:**
    ```json
    {
        "phone": "254712345678",
        "vehicleId": 123
    }
    ```
    *   `phone` (string): The Mpesa-registered phone number to receive the payment prompt.
    *   `vehicleId` (integer): The ID of the vehicle being registered.
*   **Success Response (200 OK):**
    Indicates that the STK push has been successfully initiated. The actual payment confirmation will be handled by the backend via a callback from Mpesa.
    ```json
    {
        "success": true,
        "message": "STK push for vehicle registration initiated. Please check your phone to complete the payment.",
        "checkoutRequestID": "ws_CO_..."
    }
    ```
*   **Error Response (404 Not Found):**
    ```json
    {
        "error": "Vehicle not found or does not belong to you."
    }
    ```
*   **Error Response (409 Conflict):**
    ```json
    {
        "error": "Vehicle registration is already paid for and active."
    }
    ```

#### Vehicle Registration Payment Status Notifications

After initiating an STK push for vehicle registration, the driver will receive push notifications for payment outcomes:

*   **Payment Success Notification:**
    *   **Title:** "Registration Complete!"
    *   **Body:** "Your vehicle registration payment was successful. You are now ready to go online."
    *   **Data:** `{ "type": "REGISTRATION_PAYMENT_SUCCESS", "driverId": "1" }`

*   **Payment Cancelled Notification:**
    *   **Title:** "Payment Cancelled"
    *   **Body:** "You cancelled the vehicle registration payment. Please try again when ready."
    *   **Data:** `{ "type": "REGISTRATION_PAYMENT_FAILED", "driverId": "1", "resultCode": 1032 }`

*   **Payment Failed Notification:**
    *   **Title:** "Payment Failed"
    *   **Body:** `Vehicle registration payment failed: {error_description}`
    *   **Data:** `{ "type": "REGISTRATION_PAYMENT_FAILED", "driverId": "1", "resultCode": "{result_code}" }`

### Real-time Location Updates (Driver)

*   **Method:** Use the **Firestore SDK** to directly update the driver's location. **Do not call a REST API for this.**
*   **Path:** `drivers/{driver_uid}` (where `driver_uid` is the Firebase UID).
*   **Action:** When the driver is "Online," the app should start a background task to get the device's GPS coordinates every 10-15 seconds and update the Firestore document.
*   **Data to Write:**
    ```javascript
    // When online and moving
    {
      "status": "online",
      "location": { "lat": -1.286, "lng": 36.817 },
      "updatedAt": new Date() // Use server timestamp in production
    }

    // When offline
    {
      "status": "offline",
      "updatedAt": new Date()
    }
    ```

### Managing Trips (Driver)

#### Listening for New Trips

*   **Method:** Use the **Firestore SDK** to listen for new trip requests.
*   **Path:** `trips` collection.
*   **Action:** The driver app should query the `trips` collection for documents where `status == 'requested'`. Use a real-time listener to get new requests as they are created by riders.

#### Updating Trip Status

*   **Endpoint:** `PUT /api/trips/:tripId/status`
*   **Authentication:** Custom JWT required.
*   **Description:** A driver uses this endpoint to accept a trip and update its progress.
*   **URL Parameter:**
    *   `:tripId`: The ID of the trip the driver is updating.
*   **Request Body:**
    ```json
    {
        "status": "accepted"
    }
    ```
    *   **Valid Statuses:** `accepted`, `en_route_to_pickup`, `arrived_at_pickup`, `in_progress`, `completed`, `cancelled_by_driver`.
*   **Note on `cancelled_by_driver`:** When a driver sends this status, the backend automatically re-queues the trip for other drivers by setting its status back to `requested`. The driver who cancelled will no longer see this trip request.
*   **Success Response (200 OK):**
    ```json
    {
        "success": true,
        "message": "Trip status updated to accepted."
    }
    ```

#### Push Notifications for Trip Events (Driver)

The driver app should be prepared to handle push notifications for events initiated by the rider.

*   **Rider Cancelled Trip:**
    *   **Title:** "Trip Cancelled"
    *   **Body:** "The rider has cancelled the trip."
    *   **Data:** `{ "type": "RIDER_CANCELLED", "tripId": "123" }`
    *   **Action:** When this notification is received, the driver's app should immediately stop any navigation to the pickup point and remove the trip from the driver's current task UI, making them available for new requests.


#### Get Rating History

*   **Endpoint:** `GET /api/drivers/me/ratings`
*   **Authentication:** Custom JWT required (Driver).
*   **Description:** Fetches a list of all ratings and comments the driver has received.
*   **Request Body:** None.
*   **Success Response (200 OK):**
    ```json
    {
        "success": true,
        "ratings": [
            {
                "rating": 5,
                "comment": "Very friendly and a safe driver!",
                "trip_date": "2023-10-27T10:30:00.000Z"
            },
            {
                "rating": 4,
                "comment": null,
                "trip_date": "2023-10-26T18:15:00.000Z"
            }
        ]
    }
    ```