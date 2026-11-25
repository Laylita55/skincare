                image: 'https://images.unsplash.com/photo-1608248543803-ba4f8c70ae0b?auto=format&fit=crop&q=80&w=600'
            },
            {
                id: 'm4',
                brand: 'Mixsoon',
                name: 'Mixsoon Galactomyces Sheet',
                description: 'Aclara el tono opaco y suaviza la textura dejando un acabado luminoso de piel de cristal.',
                price: 4.80,
                image: 'https://images.unsplash.com/photo-1596755389378-c31d21fd1273?auto=format&fit=crop&q=80&w=600'
            },

            // CENTELLA
            {
                id: 'c1',
                brand: 'Centella',
                name: 'Centella Ampoule Foam Mask',
                description: 'Mascarilla en ampolla concentrada para una hidratación intensiva y restauración de humedad.',
                price: 4.20,
                image: 'https://images.unsplash.com/photo-1617897903246-719242758050?auto=format&fit=crop&q=80&w=600'
            },
            {
                id: 'c2',
                brand: 'Centella',
                name: 'Centella Soothing Calming Mask',
                description: 'Especialmente diseñada para pieles con tendencia al acné o enrojecimiento. Efecto refrescante instantáneo.',
                price: 3.80,
                image: 'https://images.unsplash.com/photo-1598440947619-2c35fc9aa908?auto=format&fit=crop&q=80&w=600'
            },
            {
                id: 'c3',
                brand: 'Centella',
                name: 'Centella Hyalu-Cica Water-Fit',
                description: 'Combinación de ácido hialurónico y Centella para un impulso hidro-calmante inmediato.',
                price: 4.90,
                image: 'https://images.unsplash.com/photo-1556228578-0d85b1a4d571?auto=format&fit=crop&q=80&w=600'
            },
            {
                id: 'c4',
                brand: 'Centella',
                name: 'Centella Tea-Trica Relief Sheet',
                description: 'Enriquecida con árbol de té y centella para controlar el exceso de sebo y purificar los poros.',
                price: 4.00,
                image: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&q=80&w=600'
            }
        ];

        // ESTADO GLOBAL DEL CARRITO Y CANTIDADES
        let cart = [];
        let productQuantities = {};

        // INICIALIZACIÓN
        document.addEventListener('DOMContentLoaded', () => {
            products.forEach(p => productQuantities[p.id] = 1);
            renderProducts();
            updateCartUI();
        });

        // RENDERIZAR TARJETAS DE PRODUCTO
        function renderProducts() {
            const mixsoonContainer = document.getElementById('grid-mixsoon');
            const centellaContainer = document.getElementById('grid-centella');

            mixsoonContainer.innerHTML = '';
            centellaContainer.innerHTML = '';

            products.forEach(product => {
                const qty = productQuantities[product.id] || 1;
                const cardHTML = `
                    <div class="bg-white rounded-3xl p-4 shadow-sm border border-pink-100 card-hover flex flex-col justify-between group">
                        
                        <!-- Imagen con Click para Zoom Modal -->
                        <div onclick="openModal('${product.id}')" class="relative overflow-hidden rounded-2xl cursor-pointer aspect-square bg-pink-50 mb-4">
                            <img src="${product.image}" 
                                 onerror="this.src='https://placehold.co/600x600/FFE4E1/C71585?text=Beautyweb+Mask'" 
                                 alt="${product.name}" 
                                 class="w-full h-full object-cover object-center group-hover:scale-105 transition duration-500">
                            <div class="absolute inset-0 bg-black/20 opacity-0 group-hover:opacity-100 transition flex items-center justify-center">
                                <span class="bg-white/90 text-gray-800 text-xs font-bold px-3 py-1.5 rounded-full shadow-md flex items-center gap-1">
                                    <i class="fa-solid fa-magnifying-glass-plus"></i> Ampliar
                                </span>
                            </div>
                        </div>

                        <!-- Detalles -->
                        <div>
                            <span class="text-xs font-semibold text-pastel-magenta uppercase tracking-wider">${product.brand}</span>
                            <h3 onclick="openModal('${product.id}')" class="font-bold text-gray-800 hover:text-pastel-magenta transition cursor-pointer line-clamp-1 mt-0.5" title="${product.name}">
                                ${product.name}
                            </h3>
                            <p class="text-lg font-extrabold text-gray-900 my-2">$${product.price.toFixed(2)}</p>
                        </div>

                        <!-- Controles de Cantidad y Agregar al Carrito -->
                        <div class="space-y-3 pt-2 border-t border-gray-100">
                            <div class="flex items-center justify-between bg-pink-50/80 rounded-xl p-1">
                                <button onclick="changeQuantity('${product.id}', -1)" class="w-8 h-8 rounded-lg bg-white text-pastel-magenta font-bold hover:bg-pink-200 transition shadow-sm flex items-center justify-center">
                                    <i class="fa-solid fa-minus text-xs"></i>
                                </button>
                                <span class="font-bold text-sm text-gray-700">${qty}</span>
                                <button onclick="changeQuantity('${product.id}', 1)" class="w-8 h-8 rounded-lg bg-white text-pastel-magenta font-bold hover:bg-pink-200 transition shadow-sm flex items-center justify-center">
                                    <i class="fa-solid fa-plus text-xs"></i>
                                </button>
                            </div>

                            <button onclick="addToCart('${product.id}')" class="w-full py-2.5 rounded-xl bg-pastel-magenta hover:bg-brand-700 text-white font-bold text-xs shadow-md hover:shadow-lg transition flex items-center justify-center gap-2">
                                <i class="fa-solid fa-cart-plus"></i> Agregar al Carrito
                            </button>
                        </div>

                    </div>
                `;

                if (product.brand === 'Mixsoon') {
                    mixsoonContainer.innerHTML += cardHTML;
                } else {
                    centellaContainer.innerHTML += cardHTML;
                }
            });
        }

        // CAMBIAR CANTIDAD EN TARJETA
        function changeQuantity(productId, delta) {
            const currentQty = productQuantities[productId] || 1;
            const newQty = currentQty + delta;
            if (newQty >= 1 && newQty <= 10) {
                productQuantities[productId] = newQty;
                renderProducts();
            }
        }

        // AGREGAR AL CARRITO
        function addToCart(productId, countOverride = null) {
            const product = products.find(p => p.id === productId);
            const qtyToAdd = countOverride || productQuantities[productId] || 1;

            const existingIndex = cart.findIndex(item => item.id === productId);

            if (existingIndex > -1) {
                cart[existingIndex].quantity += qtyToAdd;
            } else {
                cart.push({
                    ...product,
                    quantity: qtyToAdd
                });
            }

            productQuantities[productId] = 1;

            renderProducts();
            updateCartUI();
            showToast(`¡${product.name} agregado al carrito!`);
        }

        // ACTUALIZAR INTERFAZ DEL CARRITO
        function updateCartUI() {
            const cartBadge = document.getElementById('cart-badge');
            const cartItemsContainer = document.getElementById('cart-items');
            const cartSubtotal = document.getElementById('cart-subtotal');
            const cartTotal = document.getElementById('cart-total');

            const totalUnits = cart.reduce((sum, item) => sum + item.quantity, 0);
            cartBadge.textContent = totalUnits;

            const subtotal = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);

            cartSubtotal.textContent = `$${subtotal.toFixed(2)}`;
            cartTotal.textContent = `$${subtotal.toFixed(2)}`;

            if (cart.length === 0) {
                cartItemsContainer.innerHTML = `
                    <div class="text-center py-12 text-gray-400">
                        <i class="fa-solid fa-basket-shopping text-5xl mb-3 text-pink-200"></i>
                        <p class="text-sm">Tu carrito está vacío</p>
                    </div>
                `;
                return;
            }

            cartItemsContainer.innerHTML = cart.map(item => `
                <div class="flex items-center justify-between p-3 bg-pink-50/50 rounded-2xl border border-pink-100">
                    <img src="${item.image}" onerror="this.src='https://placehold.co/100x100/FFE4E1/C71585?text=Mask'" alt="${item.name}" class="w-14 h-14 object-cover rounded-xl">
                    <div class="flex-grow px-3">
                        <h4 class="font-bold text-xs text-gray-800 line-clamp-1">${item.name}</h4>
                        <p class="text-xs text-gray-500">$${item.price.toFixed(2)} c/u</p>
                        <div class="flex items-center space-x-2 mt-1">
                            <button onclick="updateCartItemQty('${item.id}', -1)" class="w-5 h-5 rounded bg-white text-gray-700 text-xs font-bold hover:bg-pink-200">-</button>
                            <span class="text-xs font-bold text-gray-700">${item.quantity}</span>
                            <button onclick="updateCartItemQty('${item.id}', 1)" class="w-5 h-5 rounded bg-white text-gray-700 text-xs font-bold hover:bg-pink-200">+</button>
                        </div>
                    </div>
                    <div class="text-right">
                        <span class="font-bold text-sm text-pastel-magenta">$${(item.price * item.quantity).toFixed(2)}</span>
                        <button onclick="removeFromCart('${item.id}')" class="block text-gray-400 hover:text-red-500 text-xs mt-1">
                            <i class="fa-solid fa-trash-can"></i>
                        </button>
                    </div>
                </div>
            `).join('');
        }

        // MODIFICAR CANTIDAD DENTRO DEL CARRITO
        function updateCartItemQty(productId, delta) {
            const index = cart.findIndex(item => item.id === productId);
            if (index > -1) {
                cart[index].quantity += delta;
                if (cart[index].quantity <= 0) {
                    cart.splice(index, 1);
                }
                updateCartUI();
            }
        }

        // ELIMINAR DEL CARRITO
        function removeFromCart(productId) {
            cart = cart.filter(item => item.id !== productId);
            updateCartUI();
        }

        // TOGGLE DRAWER CARRITO
        function toggleCartDrawer() {
            const drawer = document.getElementById('cart-drawer');
            const backdrop = document.getElementById('cart-backdrop');
            const panel = document.getElementById('cart-panel');

            if (panel.classList.contains('-translate-x-full')) {
                drawer.classList.remove('pointer-events-none');
                backdrop.classList.remove('hidden');
                setTimeout(() => {
                    backdrop.classList.remove('opacity-0');
                    panel.classList.remove('-translate-x-full');
                }, 10);
            } else {
                backdrop.classList.add('opacity-0');
                panel.classList.add('-translate-x-full');
                setTimeout(() => {
                    backdrop.classList.add('hidden');
                    drawer.classList.add('pointer-events-none');
                }, 300);
            }
        }

        // MODAL DETALLE / AGRANDAR PRODUCTO
        function openModal(productId) {
            const product = products.find(p => p.id === productId);
            const modal = document.getElementById('product-modal');
            const modalContent = document.getElementById('modal-content');

            modalContent.innerHTML = `
                <div class="h-64 sm:h-auto bg-pink-50">
                    <img src="${product.image}" onerror="this.src='https://placehold.co/600x600/FFE4E1/C71585?text=Beautyweb+Mask'" alt="${product.name}" class="w-full h-full object-cover">
                </div>
                <div class="p-6 flex flex-col justify-between">
                    <div>
                        <span class="text-xs font-bold text-pastel-magenta uppercase tracking-wider">${product.brand}</span>
                        <h3 class="text-2xl font-bold text-gray-800 mt-1 mb-2">${product.name}</h3>
                        <p class="text-sm text-gray-600 mb-4 leading-relaxed">${product.description}</p>
                        <p class="text-3xl font-extrabold text-pastel-magenta mb-6">$${product.price.toFixed(2)}</p>
                    </div>

                    <div class="space-y-3">
                        <button onclick="addToCart('${product.id}', 1); closeModal();" class="w-full py-3.5 rounded-2xl bg-pastel-magenta hover:bg-brand-700 text-white font-bold text-sm shadow-lg transition">
                            <i class="fa-solid fa-cart-plus mr-2"></i>Agregar al Carrito
                        </button>
                    </div>
                </div>
            `;

            modal.classList.remove('hidden');
        }

        function closeModal() {
            document.getElementById('product-modal').classList.add('hidden');
        }

        // DESPLAZAMIENTO SUAVE
        function scrollToSection(sectionId) {
            const el = document.getElementById(sectionId);
            if (el) {
                el.scrollIntoView({ behavior: 'smooth' });
            }
        }

        // INICIAR PROCESO DE CHECKOUT
        function startCheckout() {
            if (cart.length === 0) {
                showToast('Tu carrito está vacío');
                return;
            }

            const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
            document.getElementById('payment-modal-total').textContent = `$${total.toFixed(2)}`;
            
            const input = document.getElementById('user-amount-input');
            input.value = '';
            document.getElementById('payment-error-msg').classList.add('hidden');

            toggleCartDrawer();
            document.getElementById('payment-modal').classList.remove('hidden');
            setTimeout(() => input.focus(), 100);
        }

        function closePaymentModal() {
            document.getElementById('payment-modal').classList.add('hidden');
        }

     
       // PROCESAR Y VALIDAR EL PAGO INGRESADO
        async function processPayment() {
            const total = cart.reduce((sum, item) => sum + (item.price * item.quantity), 0);
            const inputEl = document.getElementById('user-amount-input');
            const errorMsgEl = document.getElementById('payment-error-msg');
            const errorTextEl = document.getElementById('payment-error-text');

            const paidAmount = parseFloat(inputEl.value);

            if (isNaN(paidAmount) || paidAmount <= 0) {
                errorTextEl.textContent = 'Por favor, ingresa un monto válido.';
                errorMsgEl.classList.remove('hidden');
                return;
            }

            if (paidAmount < total) {
                const faltante = (total - paidAmount).toFixed(2);
                errorTextEl.textContent = `El monto es insuficiente. Falta $${faltante} para cubrir el total ($${total.toFixed(2)}).`;
                errorMsgEl.classList.remove('hidden');
                return;
            }

            errorMsgEl.classList.add('hidden');
            const change = paidAmount - total;

            // --- CONEXIÓN CON LA BASE DE DATOS ---
            try {
                await fetch('/api/ventas', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        productos: cart.map(item => ({
                            id: item.id,
                            nombre: item.name,
                            cantidad: item.quantity,
                            precioUnitario: item.price
                        })),
                        total: total,
                        montoPagado: paidAmount,
                        vuelto: change
                    })
                });
            } catch (error) {
                console.error('Error al registrar la venta en el servidor:', error);
            }

            // Mostrar datos en el modal de recibo y vaciar carrito
            document.getElementById('receipt-total').textContent = `$${total.toFixed(2)}`;
            document.getElementById('receipt-paid').textContent = `$${paidAmount.toFixed(2)}`;
            document.getElementById('receipt-change').textContent = `$${change.toFixed(2)}`;

            closePaymentModal();
            cart = [];
            updateCartUI();
            document.getElementById('receipt-modal').classList.remove('hidden');
        }

        function closeReceiptModal() {
            document.getElementById('receipt-modal').classList.add('hidden');
        }

        // MOSTRAR TOAST NOTIFICACIÓN
        function showToast(message) {
            const toast = document.getElementById('toast');
            const toastMsg = document.getElementById('toast-message');

            toastMsg.textContent = message;
            toast.classList.remove('translate-y-20', 'opacity-0');

            setTimeout(() => {
                toast.classList.add('translate-y-20', 'opacity-0');
            }, 3000);
        }
    </script>
</body>
</html>
EOF

tail -n 5 ~/www/index.html
python3 -m http.server 8080
cd~
cd ~/backend
npm install express mysql2 cors
cat << 'EOF' > ~/backend/index.js
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const dbConfig = {
  host: '127.0.0.1',
  user: 'root',
  password: '',
  database: 'test'
};

app.post('/api/compras', async (req, res) => {
  try {
    const { cliente, producto, cantidad, total } = req.body;
    if (!cliente || !producto || !total) {
      return res.status(400).json({ error: 'Faltan datos obligatorios' });
    }

    const conn = await mysql.createConnection(dbConfig);
    const [result] = await conn.execute(
      'INSERT INTO compras (cliente, producto, cantidad, total) VALUES (?, ?, ?, ?)',
      [cliente, producto, Number(cantidad) || 1, Number(total)]
    );
    await conn.end();

    res.status(201).json({ ok: true, id: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al guardar la compra' });
  }
});

app.get('/api/compras', async (req, res) => {
  try {
    const conn = await mysql.createConnection(dbConfig);
    const [rows] = await conn.execute('SELECT * FROM compras ORDER BY id DESC');
    await conn.end();
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Error al consultar compras' });
  }
});

app.get('/compras', async (req, res) => {
  try {
    const conn = await mysql.createConnection(dbConfig);
    const [rows] = await conn.execute('SELECT * FROM compras ORDER BY id DESC');
    await conn.end();

    const filasHtml = rows.map(c => `
      <tr>
        <td>${c.id}</td>
        <td>${c.cliente}</td>
        <td>${c.producto}</td>
        <td>${c.cantidad}</td>
        <td>$${Number(c.total).toFixed(2)}</td>
        <td>${new Date(c.creado_en).toLocaleString()}</td>
      </tr>
    `).join('');

    res.send(`
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Panel de Compras</title>
        <style>
          body { font-family: sans-serif; padding: 20px; background: #111; color: #eee; }
          table { width: 100%; border-collapse: collapse; margin-top: 16px; }
          th, td { border: 1px solid #333; padding: 8px; text-align: left; }
          th { background: #222; }
        </style>
      </head>
      <body>
        <h1>Compras registradas</h1>
        <table>
          <thead>
            <tr>
              <th>ID</th><th>Cliente</th><th>Producto</th><th>Cant.</th><th>Total</th><th>Fecha</th>
            </tr>
          </thead>
          <tbody>
            ${filasHtml || '<tr><td colspan="6">Sin compras aún</td></tr>'}
          </tbody>
        </table>
      </body>
      </html>
    `);
  } catch (err) {
    console.error(err);
    res.status(500).send('Error al cargar el panel de compras');
  }
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`Backend corriendo en http://localhost:${PORT}`);
  console.log(`Ver compras en http://localhost:${PORT}/compras`);
});
EOF

node ~/backend/index.js
