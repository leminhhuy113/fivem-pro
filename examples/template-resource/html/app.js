// Minimal NUI bridge: listens for open/close, posts callbacks back to Lua.
const app = document.getElementById('app');

window.addEventListener('message', (e) => {
    const action = e.data.action;
    if (action === 'open') app.classList.remove('hidden');
    if (action === 'close') app.classList.add('hidden');
});

async function post(name, data = {}) {
    const res = await fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify(data),
    });
    return res.json();
}

document.getElementById('claim').addEventListener('click', () => post('claimReward'));
document.getElementById('close').addEventListener('click', () => post('close'));
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') post('close');
});
