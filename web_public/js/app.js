// Main Application Logic
// Handles product fetching, search, filtering, and display

// State Management
let allProducts = [];
let filteredProducts = [];
let selectedCategory = 'all';

// DOM Elements
const searchInput = document.getElementById('searchInput');
const scanBtn = document.getElementById('scanBtn');
const closeScanner = document.getElementById('closeScanner');
const productsGrid = document.getElementById('productsGrid');
const loading = document.getElementById('loading');
const error = document.getElementById('error');
const emptyState = document.getElementById('emptyState');
const categoryChips = document.querySelectorAll('.category-chip');

// ===================================
// INITIALIZATION
// ===================================
document.addEventListener('DOMContentLoaded', () => {
    console.log('🚀 App initialized');
    loadProducts();
    setupEventListeners();
});

// ===================================
// EVENT LISTENERS
// ===================================
function setupEventListeners() {
    // Search input
    searchInput.addEventListener('input', (e) => {
        handleSearch(e.target.value);
    });

    // Scan button
    scanBtn.addEventListener('click', () => {
        scanner.start((barcode) => {
            console.log('Scanned barcode:', barcode);
            searchByBarcode(barcode);
        });
    });

    // Close scanner
    closeScanner.addEventListener('click', () => {
        scanner.stop();
    });

    // Category filter
    categoryChips.forEach(chip => {
        chip.addEventListener('click', () => {
            const category = chip.dataset.category;
            selectCategory(category);
        });
    });
}

// ===================================
// FIREBASE - LOAD PRODUCTS
// ===================================
async function loadProducts() {
    try {
        console.log('📦 Loading products from Firestore...');
        showLoading();

        const snapshot = await db.collection('products').get();

        allProducts = snapshot.docs.map(doc => ({
            id: doc.id,
            ...doc.data()
        }));

        console.log(`✅ Loaded ${allProducts.length} products`);

        filteredProducts = [...allProducts];
        displayProducts();

    } catch (err) {
        console.error('❌ Error loading products:', err);
        showError('Gagal memuat data produk. Periksa koneksi internet Anda.');
    }
}

// ===================================
// SEARCH & FILTER
// ===================================
function handleSearch(query) {
    const searchTerm = query.toLowerCase().trim();

    filteredProducts = allProducts.filter(product => {
        const nameMatch = product.name?.toLowerCase().includes(searchTerm) || false;
        const categoryMatch = selectedCategory === 'all' || product.category === selectedCategory;

        return nameMatch && categoryMatch;
    });

    displayProducts();
}

function searchByBarcode(barcode) {
    console.log('🔍 Searching for barcode:', barcode);

    filteredProducts = allProducts.filter(product => {
        return product.barcode === barcode;
    });

    if (filteredProducts.length === 0) {
        alert(`Produk dengan barcode "${barcode}" tidak ditemukan.`);
        filteredProducts = [...allProducts];
    } else {
        searchInput.value = '';
        console.log(`✅ Found ${filteredProducts.length} product(s)`);
    }

    displayProducts();
}

function selectCategory(category) {
    selectedCategory = category;

    // Update active chip
    categoryChips.forEach(chip => {
        if (chip.dataset.category === category) {
            chip.classList.add('active');
        } else {
            chip.classList.remove('active');
        }
    });

    // Filter products
    const searchTerm = searchInput.value.toLowerCase().trim();

    filteredProducts = allProducts.filter(product => {
        const nameMatch = !searchTerm || product.name?.toLowerCase().includes(searchTerm);
        const categoryMatch = category === 'all' || product.category === category;

        return nameMatch && categoryMatch;
    });

    displayProducts();
}

// ===================================
// DISPLAY PRODUCTS
// ===================================
function displayProducts() {
    hideAllStates();

    if (filteredProducts.length === 0) {
        showEmptyState();
        return;
    }

    productsGrid.innerHTML = '';

    filteredProducts.forEach(product => {
        const card = createProductCard(product);
        productsGrid.appendChild(card);
    });

    productsGrid.style.display = 'grid';
}

function createProductCard(product) {
    const card = document.createElement('div');
    card.className = 'product-card';

    // Product Image
    const imageDiv = document.createElement('div');
    imageDiv.className = 'product-image';

    if (product.images && product.images.length > 0) {
        const firstImage = product.images[0];

        // Check if it's a URL or base64
        if (firstImage.startsWith('http')) {
            const img = document.createElement('img');
            img.src = firstImage;
            img.alt = product.name || 'Product';
            img.onerror = () => {
                // Fallback to icon if image fails to load
                img.remove();
                const icon = document.createElement('span');
                icon.className = 'material-icons';
                icon.textContent = 'inventory_2';
                imageDiv.appendChild(icon);
            };
            imageDiv.appendChild(img);
        } else {
            // Base64 image
            const img = document.createElement('img');
            img.src = `data:image/jpeg;base64,${firstImage}`;
            img.alt = product.name || 'Product';
            img.onerror = () => {
                img.remove();
                const icon = document.createElement('span');
                icon.className = 'material-icons';
                icon.textContent = 'inventory_2';
                imageDiv.appendChild(icon);
            };
            imageDiv.appendChild(img);
        }

        // Image count badge
        if (product.images.length > 1) {
            const badge = document.createElement('span');
            badge.className = 'image-count';
            badge.textContent = `+${product.images.length - 1}`;
            imageDiv.appendChild(badge);
        }
    } else {
        // No image - show icon
        const icon = document.createElement('span');
        icon.className = 'material-icons';
        icon.textContent = 'inventory_2';
        imageDiv.appendChild(icon);
    }

    card.appendChild(imageDiv);

    // Product Info
    const infoDiv = document.createElement('div');
    infoDiv.className = 'product-info';

    const name = document.createElement('h3');
    name.textContent = product.name || 'Tanpa Nama';
    infoDiv.appendChild(name);

    const price = document.createElement('div');
    price.className = 'product-price';
    price.textContent = `Rp ${formatPrice(product.price || 0)}`;
    infoDiv.appendChild(price);

    const category = document.createElement('span');
    category.className = 'product-category';
    category.textContent = product.category || 'Lainnya';
    infoDiv.appendChild(category);

    if (product.barcode) {
        const barcode = document.createElement('div');
        barcode.className = 'product-barcode';
        barcode.textContent = `Barcode: ${product.barcode}`;
        infoDiv.appendChild(barcode);
    }

    card.appendChild(infoDiv);

    return card;
}

// ===================================
// UI STATE MANAGEMENT
// ===================================
function showLoading() {
    hideAllStates();
    loading.style.display = 'block';
}

function showError(message) {
    hideAllStates();
    document.getElementById('errorMessage').textContent = message;
    error.style.display = 'block';
}

function showEmptyState() {
    hideAllStates();
    emptyState.style.display = 'block';
}

function hideAllStates() {
    loading.style.display = 'none';
    error.style.display = 'none';
    emptyState.style.display = 'none';
    productsGrid.style.display = 'none';
}

// ===================================
// UTILITIES
// ===================================
function formatPrice(price) {
    return price.toString().replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

// ===================================
// ERROR HANDLING
// ===================================
window.addEventListener('error', (e) => {
    console.error('Global error:', e.error);
});

window.addEventListener('unhandledrejection', (e) => {
    console.error('Unhandled promise rejection:', e.reason);
});
