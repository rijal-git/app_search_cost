// Barcode Scanner Module
// Using Html5-QRCode library for web-based barcode scanning

class BarcodeScanner {
    constructor() {
        this.html5QrCode = null;
        this.isScanning = false;
        this.onScanSuccess = null;
    }

    // Initialize scanner
    async start(onSuccess) {
        this.onScanSuccess = onSuccess;
        const modal = document.getElementById('scannerModal');
        modal.classList.add('active');

        if (!this.html5QrCode) {
            this.html5QrCode = new Html5Qrcode("reader");
        }

        try {
            await this.html5QrCode.start(
                { facingMode: "environment" }, // Use back camera on mobile
                {
                    fps: 10,
                    qrbox: { width: 250, height: 250 },
                    aspectRatio: 1.0
                },
                (decodedText, decodedResult) => {
                    console.log(`✅ Barcode detected: ${decodedText}`);
                    this.handleScanSuccess(decodedText);
                },
                (errorMessage) => {
                    // Scan error (can be ignored, happens frequently)
                }
            );

            this.isScanning = true;
            console.log('📷 Scanner started');
        } catch (err) {
            console.error('❌ Scanner error:', err);
            alert('Tidak dapat mengakses kamera. Pastikan izin kamera telah diberikan.');
            this.stop();
        }
    }

    // Handle successful scan
    handleScanSuccess(barcode) {
        console.log('🔍 Processing barcode:', barcode);

        // Stop scanner
        this.stop();

        // Call success callback
        if (this.onScanSuccess) {
            this.onScanSuccess(barcode);
        }
    }

    // Stop scanner
    async stop() {
        if (this.html5QrCode && this.isScanning) {
            try {
                await this.html5QrCode.stop();
                this.isScanning = false;
                console.log('🛑 Scanner stopped');
            } catch (err) {
                console.error('Error stopping scanner:', err);
            }
        }

        const modal = document.getElementById('scannerModal');
        modal.classList.remove('active');
    }
}

// Export scanner instance
const scanner = new BarcodeScanner();
