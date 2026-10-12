# Diagrams - All Figures Visible

## Figure 1: Architecture Overview
![Figure 1](../demo/image_20261012_114904.png)

Files:
- ../demo/image_20261012_114904.png (1.2 MB PNG Primary)
- ../demo/image_20261012_114904.jpg (590 KB JPG Backup)
- ../demo/image_20261012_114904.webp (353 KB WEBP)

## Figure 2: RPO/RTO Timeline
![Figure 2](../demo/image_20261012_114941.png)

Files:
- ../demo/image_20261012_114941.png (1.3 MB PNG Primary)
- ../demo/image_20261012_114941.jpg (635 KB JPG Backup)
- ../demo/image_20261012_114941.webp (369 KB WEBP)

## How to View
1. On GitHub: Go to demo/ folder - GitHub auto-previews PNG/JPG
2. Locally: Open demo/index.html
3. In PDFs: Both figures embedded in PaySecure-Final-Submission-With-Diagrams.pdf


## 🌐 Live Website & Demo Links (Added)

### 1. Main Demo Website (Interactive - Hostable)
- **Local File:** `demo/index.html` - Open in browser to see Figure 1 + Figure 2 VISIBLE + failover simulation
- **Interactive Demo:** `demo/PaySecure-Demo-VISIBLE.html` - Pay button + Simulate Mumbai Failure T+150ms + No Double Debit proof
- **How to Host Live Website (Free):**
  ```bash
  # Option 1: Vercel (Recommended)
  npm i -g vercel
  cd demo
  vercel --prod
  # Your site will be live at https://paysecure-dr-demo.vercel.app

  # Option 2: Netlify Drop
  # Drag demo/ folder to https://app.netlify.com/drop
  # Live in 10 seconds

  # Option 3: GitHub Pages
  # Push repo -> Settings -> Pages -> Source: main branch /demo folder
  # Live at https://YOUR_USERNAME.github.io/PaySecure-DR-Project/
  ```

### 2. Architecture Diagrams - Direct Links (Visible on GitHub)
- **Figure 1 - Architecture Overview (Live on GitHub):**
  - GitHub Preview: `demo/image_20261012_114904.png` [View on GitHub](demo/image_20261012_114904.png)
  - Backup JPG: `demo/image_20261012_114904.jpg`
  - WEBP: `demo/image_20261012_114904.webp`
  - [Open demo/index.html to see Figure 1 VISIBLE](demo/index.html)

- **Figure 2 - RPO/RTO Timeline (Live on GitHub):**
  - GitHub Preview: `demo/image_20261012_114941.png` [View on GitHub](demo/image_20261012_114941.png)
  - Backup JPG: `demo/image_20261012_114941.jpg`
  - WEBP: `demo/image_20261012_114941.webp`
  - [Open demo/index.html to see Figure 2 VISIBLE](demo/index.html)

### 3. Final Submission PDFs (With Diagrams Embedded)
- `PaySecure-Final-Submission-With-Diagrams.pdf` - Page 2: Figure 1, Page 3: Figure 2
- `PaySecure-FINAL-VISIBLE-CODE-DIAGRAMS.pdf` - Full code visible + diagrams

### 4. How Merchant Website Uses This DR Infra (Website Link Flow)
**Your merchant website (e.g., shop.paysecure.in) calls PaySecure Gateway:**
```javascript
// shop.paysecure.in/checkout.js - This is the website link
fetch('https://api.paysecure.in/v1/pay', {
  method: 'POST',
  headers: { 
    'X-Idempotency-Key': 'order_12345', // Prevents double debit
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ amount: 2500, upi_id: 'user@okaxis' })
})
// Behind api.paysecure.in is this DR architecture:
// Route53 10s HC -> Mumbai ACTIVE (6 replicas) -> DynamoDB (20ms) -> Aurora (30ms) -> MSK (40ms)
// If Mumbai fails, auto-failover to Hyderabad in <5min, RPO <1s, no double debit
```

**Live Demo Website Code:**
- See `demo/index.html` - Contains working Pay button + failure simulation + visible diagrams + all fixed code
- This demo IS the website that uses the DR infrastructure

