<?php

// Hata raporlamayı etkinleştir
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Veritabanı bağlantısı
$servername = "xxxxxx";
$username = "xxxxxx";
$password = "xxxxxx";
$dbname = "xxxxxx";

try {
    $pdo = new PDO("mysql:host=$servername;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Veritabanı bağlantısı başarısız: " . $e->getMessage());
}

// FlightService API URL ve API Key
$apiKey = 'xxxxxx';
$baseUrl = 'http://api.aviationstack.com/v1';

// İzmir Adnan Menderes Havalimanı Koordinatları
$adnanMenderesLat = 38.2924;
$adnanMenderesLng = 27.1567;

// `yolcu_olustur` tablosundaki tüm yolcuları al
$yolcuQuery = "SELECT * FROM yolcu_olustur";
$yolcuStmt = $pdo->query($yolcuQuery);
$yolcular = $yolcuStmt->fetchAll();

foreach ($yolcular as $yolcuData) {
    try {
        $pnr = $yolcuData['pnr'];
        $yolcuUsername = $yolcuData['username'];
        $varisNoktasi = $yolcuData['varis_noktasi'];
        $varisNoktasiYazili = $yolcuData['varis_noktasi_yazili'];
        $assignedDriver = $yolcuData['driver_username'];

        // API'ye PNR sorgusu yap
        $apiUrl = "$baseUrl/flights?access_key=$apiKey&flight_iata=" . $pnr;
        $apiResponse = @file_get_contents($apiUrl);

        if ($apiResponse === FALSE) {
            echo "API çağrısı başarısız! (PNR: $pnr)<br>";
            continue;
        }

        $journeyInfo = json_decode($apiResponse, true);

        $routeStart = 'Bilinmiyor';
        $routeEnd = 'Bilinmiyor';
        $estimatedArrival = 'Bilinmiyor';
        $actualStartTime = 'Bilinmiyor';
        $actualEndTime = 'Bilinmiyor';
        $flightStatus = 'Bilinmiyor';

        if ($journeyInfo && isset($journeyInfo['data'][0])) {
            $departure = $journeyInfo['data'][0]['departure'];
            $arrival = $journeyInfo['data'][0]['arrival'];
            $flightStatus = $journeyInfo['data'][0]['flight_status'];

            $routeStart = $departure['airport'] ?? 'Bilinmiyor';
            $routeEnd = $arrival['airport'] ?? 'Bilinmiyor';
            $estimatedArrival = $arrival['estimated'] ?? 'Bilinmiyor'; // Tahmini varış
            $actualStartTime = $departure['scheduled'] ?? 'Bilinmiyor';
            $actualEndTime = $arrival['scheduled'] ?? 'Bilinmiyor';

            // Durumları Türkçeye çevir
            $statusTranslations = [
                'scheduled' => 'Planlandı',
                'active' => 'Aktif',
                'landed' => 'İndi',
                'cancelled' => 'İptal Edildi',
                'incident' => 'Olay',
                'diverted' => 'Yönlendirildi'
            ];
            $flightStatus = $statusTranslations[$flightStatus] ?? $flightStatus;
        } else {
            echo "API'den veriler alınamadı! (PNR: $pnr)<br>";
            continue;
        }

        if ($estimatedArrival === 'Bilinmiyor') {
            echo "Tahmini varış bilgisi alınamadı! (PNR: $pnr)<br>";
            continue;
        }

        $estimatedArrivalTime = new DateTime($estimatedArrival);
        $availabilityCheckStart = $estimatedArrivalTime->format('Y-m-d H:i:s');
        $availabilityCheckEnd = $estimatedArrivalTime->modify('+1 hour')->format('Y-m-d H:i:s');

        // Journeys tablosunda PNR'yi kontrol et
        $checkJourneyQuery = "SELECT * FROM journeys WHERE pnr = ?";
        $checkStmt = $pdo->prepare($checkJourneyQuery);
        $checkStmt->execute([$pnr]);
        $existingJourney = $checkStmt->fetch();

        if ($existingJourney) {
            $updateQuery = "UPDATE journeys SET
                yolcu_username = ?, 
                route_start_location = ?, 
                route_end_location = ?, 
                route_end_taksi = ?, 
                route_end_taksi_yazili = ?, 
                estimated_duration = ?, 
                actual_start_time = ?, 
                actual_end_time = ?, 
                status = ?
                WHERE pnr = ?";

            $updateStmt = $pdo->prepare($updateQuery);
            $updateStmt->execute([
                $yolcuUsername, $routeStart, $routeEnd, $varisNoktasi, $varisNoktasiYazili,
                $estimatedArrival, $actualStartTime, $actualEndTime, $flightStatus, $pnr
            ]);

            echo "Yolculuk güncellendi (PNR: $pnr)<br>";
            continue;
        }

        if ($assignedDriver) {
            // Uygun sürücü bulundu, yolculuk kaydı oluştur
            $insertQuery = "INSERT INTO journeys (driver_username, yolcu_username, pnr, route_start_location, route_end_location, route_end_taksi, route_end_taksi_yazili, estimated_duration, actual_start_time, actual_end_time, status)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            $insertStmt = $pdo->prepare($insertQuery);
            $insertStmt->execute([
                $assignedDriver, $yolcuUsername, $pnr, $routeStart, $routeEnd, $varisNoktasi, $varisNoktasiYazili,
                $estimatedArrival, $actualStartTime, $actualEndTime, $flightStatus
            ]);

            echo "Yeni yolculuk oluşturuldu ve sürücü atandı: $assignedDriver (PNR: $pnr)<br>";
        } else {
            echo "Uygun sürücü bulunamadı! (PNR: $pnr)<br>";
        }
    } catch (Exception $e) {
        echo "Bir hata oluştu: " . $e->getMessage() . " (PNR: $pnr)<br>";
        continue;
    }
}

?>