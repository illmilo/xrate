<img align="right" width="75px" src="assets/images/main_logo.png">

# XRate
Exchange rates & P2P money transfer Android app.

---
[//]: # (## You can perform some actions with the <a href="https://github.com/adedayoniyi/Pay-Mobile-Web-Admin"> Pay Mobile Web Admin </a>)
## Features
1. Additional security with pin authorization
2. Push and in-app notifications
3. Customer service support 
4. Responsive design
5. Safe XRate account creation and maintenance

## Usage

[//]: # (#### Visit:<a href="https://github.com/adedayoniyi/Pay-Mobile-Full-Stack"> Pay Mobile Full Stack </a> to access the full stack code of the software &#40;i.e the Back End and the Web Admin Front End&#41;)

- View current exchange rates 
- Transfer money with one tap
- View transaction details 
- Create rate alerts

## Installation

1. Clone repo
2. Install dependencies
```bash
flutter pub get
```
3. Configure the server (optionally)
4. Locate to `lib/core/utils/global_constants.dart` and link the project to your server (optionally)
```dart
const String uri = "your_uri_address";
```
5. Run `main.dart`

## Dependencies

1. <a href="https://pub.dev/packages?q=provider">provider</a>
2. <a href="https://pub.dev/packages/shared_preferences">shared_preferences</a>
3. <a href="https://pub.dev/packages/http">http</a>
4. <a href="https://pub.dev/packages/intl">intl</a>
5. <a href="https://pub.dev/packages/internet_connection_checker">internet_connrction_checker</a>

6. <a href="https://pub.dev/packages/flutter_native_splash">flutter_native_splash</a>
7. <a href="https://pub.dev/packages/firebase_core">firebase_core</a>
8. <a href="https://pub.dev/packages/firebase_messaging">firebase_messaging</a>
9. <a href="https://pub.dev/packages/cloud_firestore">cloud_firestore</a>
10. <a href="https://pub.dev/packages/socket_io_client">socket_io_client</a>
11. <a href="https://pub.dev/packages/awesome_notifications">awesome_notifications</a>

### Test Login
```json
[
  {
  "username":"lere",
  "pin":"7171",
  "password":"test123"
  },
  {
    "username":"johndoe",
    "pin":"7171",
    "password":"test123"
  },
  {
    "username":"alice",
    "pin":"7070",
    "password":"test123"
  },
  {
    "username":"bob",
    "pin":"7474",
    "password":"test123"
  }
]
```

[//]: # (## This is the official Nodejs server code that this app is running on <a href="https://github.com/adedayoniyi/Pay-Mobile-Server">Pay Mobile Server</a>)

## Contribution

Pull requests are welcome. If you encounter any problem with the app or server, you can open an 
issue. This project was forked from 
[here](https://github.com/adedayoniyi/Pay-Mobile-P2P-Money-Transfer-App),
globally modified and made into an independent project under the limitations of MIT License.

## License

This project is licensed under the MIT License - see [LICENSE](LICENSE) for details.
