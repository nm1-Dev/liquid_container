const laptop = document.querySelector('.laptop');
const zonesList = document.getElementById('zones');
const rewardsList = document.getElementById('reward-list');
const logBox = document.getElementById('log');
let allZones = [];

function logMessage(msg, tone = "info", animated = false) {
    const time = new Date().toLocaleTimeString();
    const color = tone === "error" ? "text-danger" : (tone === "ok" ? "text-success" : "text-primary");
    const line = document.createElement("div");
    line.innerHTML = `<span class="${color}">[${time}]</span> `;
    logBox.appendChild(line);

    if (animated) {
        let i = 0;
        const text = msg;
        const interval = setInterval(() => {
            line.innerHTML += text.charAt(i);
            i++;
            if (i >= text.length) clearInterval(interval);
            logBox.scrollTop = logBox.scrollHeight;
        }, 25);
    } else {
        line.innerHTML += msg;
    }
    logBox.scrollTop = logBox.scrollHeight;
}

function renderZones(zones) {
    allZones = zones;
    zonesList.innerHTML = '';
    for (const k in zones) {
        const z = zones[k];
        zonesList.insertAdjacentHTML('beforeend', `
      <div class="list-group-item bg-transparent text-light d-flex justify-content-between align-items-center">
        <div>
          <i class="fa-solid fa-location-dot text-danger me-2"></i>
          <strong>${z.name}</strong>
          <small class="text-secondary d-block">R: ${z.radius.toFixed(0)} • ${z.coord.x.toFixed(1)}, ${z.coord.y.toFixed(1)}</small>
        </div>
      </div>
    `);
    }
}

function renderRewards(list) {
    rewardsList.innerHTML = '';
    list.forEach(r => {
        rewardsList.insertAdjacentHTML('beforeend', `
      <li class="mb-1"><i class="fa-solid ${r.icon} me-2 text-danger"></i>${r.label}</li>
    `);
    });
}

window.addEventListener('message', (event) => {
    const data = event.data;
    if (data?.type === 'open') {
        laptop.style.display = 'block';
        renderZones(data.zones || {});
        renderRewards(data.rewards || []);
        logMessage("Merryweather Control Online...", "ok", true);
    } else if (data?.type === 'close') {
        laptop.style.display = 'none';
    }
});

document.getElementById('start-war').addEventListener('click', () => {
    const btn = document.getElementById('start-war');

    // Disable button immediately to prevent spam
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin me-2"></i> Deploying...';

    if (!allZones || Object.keys(allZones).length === 0) {
        logMessage("No zones available in server config.", "error");
        btn.disabled = false;
        btn.innerHTML = '<i class="fa-solid fa-shuffle me-2"></i> Randomize & Deploy';
        return;
    }

    // Randomize
    const keys = Object.keys(allZones);
    const randomKey = keys[Math.floor(Math.random() * keys.length)];
    const zone = allZones[randomKey];

    logMessage("Randomizing deployment coordinates...", "info", true);

    setTimeout(() => {
        logMessage(`Target Zone Acquired: ${zone.name}`, "ok", true);

        // Send to server
        fetch(`https://${GetParentResourceName()}/startContainerWar`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify({ zoneId: zone.id })
        }).then(() => {
            logMessage(`Deployment order sent to ${zone.name}`, "ok", true);

            // Re-enable button after short delay
            setTimeout(() => {
                btn.disabled = false;
                btn.innerHTML = '<i class="fa-solid fa-shuffle me-2"></i> Randomize & Deploy';
            }, 3000);

        }).catch(() => {
            logMessage("Failed to send to server.", "error");
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-shuffle me-2"></i> Randomize & Deploy';
        });
    }, 800);
});

document.getElementById('close').addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/closeUI`, { method: 'POST' });
});
