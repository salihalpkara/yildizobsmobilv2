# Yıldız OBS Mobil v2 (Yildiz OBS Mobile v2)

## EN

This application is the improved version of my previous project [Yıldız OBS Mobile](https://github.com/salihalpkara/yildizobsmobil/). Yildiz OBS Mobile v2 provides a one-click-login experience for both E-Government and OBS login methods.

During the onboarding setup screen, the application prompts the student to select their preferred login method (E-Government login or OBS login). Subsequently, the application requests the necessary information based on the chosen login method. Once the required information which will be stored locally on the student's device is provided, they can opt to set up biometric authentication, adding an extra layer of protection. Consequently, the app will require biometric authentication for every login attempt.

Upon completion of the setup process, the student is ready to experience one-click-login. The application automatically logs in to OBS using the preferred method upon launch.

I have already successfully implemented the E-Government login functionality in the previous version. In this version, I have optimized the function calls to eliminate the need for users to click the login button separately.

Additionally, I have implemented the one-click-login feature for the OBS login option. This was not applicable in the previous version due to the inability to automatically solve the security question. However, in this version, I have managed to overcome this challenge by using the Google ML Kit package.

Through this project, I learned how to utilize the Google ML Kit package and had the opportunity to experiment with and learn about the various functions of the InAppWebView package. Additionally, I learned how to design an initial setup screen for my application and guide users through the interface to efficiently utilize my application.

## TR

Bu uygulama, önceki projem [Yıldız OBS Mobil](https://github.com/salihalpkara/yildizobsmobil/)'in geliştirilmiş versiyonudur. Yıldız OBS Mobil v2, E-Devlet ve OBS giriş yöntemleri için tek tıklamayla giriş deneyimi sunar.

Öğrenci, kurulum ekranında tercih ettiği giriş yöntemini (E-Devlet girişi veya OBS girişi) seçmek için yönlendirilir. Ardından, uygulama seçilen giriş yöntemine göre gerekli bilgileri alır. Kullanıcının cihazında yerel olarak saklanacak olan bu gerekli bilgiler sağlandıktan sonra, öğrenciye ek bir koruma katmanı eklemek için biyometrik kimlik doğrulaması kurma seçeneği sunulur. Böylelikle, uygulama her girişte biyometrik kimlik doğrulaması yapmayı gerektirir.

Kurulum süreci tamamlandığında, kullanıcı tek tıklamayla giriş deneyimini yaşamaya hazırdır. Uygulama, başlatıldığında tercih edilen yöntemi kullanarak OBS'ye otomatik olarak giriş yapar.

Önceki versiyonda E-Devlet girişi işlevselliğini başarıyla uygulamıştım. Bu versiyonda, kullanıcıların ayrıca giriş düğmesine tıklama ihtiyacını ortadan kaldırmak için fonksiyon çağrılarını optimize ettim.

Ayrıca, OBS giriş seçeneği için tek tıklamayla giriş özelliğini uyguladım. Bu önceki versiyonda güvenlik sorusunu otomatik olarak çözemediğim için mümkün değildi. Ancak bu versiyonda, bu sorunu Google ML Kit paketini kullanarak çözmeyi başardım.

Bu proje sayesinde Google ML Kit paketini kullanmayı öğrendim ve InAppWebView paketinin farklı fonksiyonlarını deneme ve öğrenme imkanını elde ettim. Bunlara ek olarak uygulamam için bir başlangıç kurulum ekranı tasarlamayı ve kullanıcıları uygulamamı verimli bir şekilde kullanabilmeleri için arayüz aracılığıyla yönlendirmeyi öğrendim.
