// ==UserScript==
// @name         Retale | LEC
// @namespace    none
// @version      0.2.6 BETA
// @description  In Create
// @author       Dredlex
// @match        *://venge.io/*
// @require      https://cdn.jsdelivr.net/npm/tweakpane@1.5.4/dist/tweakpane.min.js
// @require      https://pastebin.com/raw/hTdbYWYG
// @grant        none
// ==/UserScript==
 window.document.title ="Venge.io | Mod";

var Hack = function() {
	this.settings = {
		infAmmo: true,
		infJump: true,
        noRecoil: true,
		autoKill: true,
		speedMlt: 0,
        esp: true,
        aimbot: true,
        rage: true,
        turboshoot: true,
        timeScale: 0,
        noAbcooldown: false

	};
	this.hooks = {
		network: null,
		movement: null,
		anticheat: null
	};

	this.setupHooks = function() {
		this.waitForProp("Movement").then(this.hookMovement).catch(e => console.log(e));
		this.waitForProp("NetworkManager").then(this.hookNetwork).catch(e => console.log(e));
		this.waitForProp("VengeGuard").then(this.hookAnticheat).catch(e => console.log(e));
		this.waitForProp("Label").then(this.hookLabel).catch(e => console.log(e));
	};

	this.setupBinds = function() {
		window.addEventListener("keydown", (e) => {
            switch(e.keyCode) {
                case 33: // Numpad9
                    this.settings.autoKill = !this.settings.autoKill;
                    this.hooks.network.app.fire("Chat:Message", "Client", "Kill on Respawn - " + (this.settings.autoKill?"True":"False"), !0)
                    break;
                case 34: // Numpad3
                    this.settings.infAmmo = !this.settings.infAmmo;
                    this.hooks.network.app.fire("Chat:Message", "Client", "Infinite Ammo - " + (this.settings.infAmmo?"True":"False"), !0)
                    break;
                case 12: // Numpad5
                    this.settings.aimbot = !this.settings.aimbot;
                    this.hooks.network.app.fire("Chat:Message", "Client", "Aimlock - " + (this.settings.aimbot?"True":"False"), !0)
                    break;
                case 37: // Numpad4
                    this.settings.infJump = !this.settings.infJump;
                    this.hooks.network.app.fire("Chat:Message", "Client", "Fly Hacks - " + (this.settings.infJump?"True":"False"), !0)
                    break;
                case 40: // Numpad2
                    this.settings.speedMlt++;
                    if (this.settings.speedMlt > 4) this.settings.speedMlt = 0;
                    this.hooks.network.app.fire("Chat:Message", "Client", "Speed Multiplier - " + (this.settings.speedMlt + 1) + "x", !0)
                    break;
                case 35: // Numpad1
                    this.settings.esp = !this.settings.esp;
                    this.hooks.network.app.fire("Chat:Message", "Client", "Wallhacks - " + (this.settings.esp?"True":"False"), !0)
                    break;
                case 39: // Numpad6
                    this.settings.timeScale++;
                    if (this.settings.timeScale > 4) this.settings.timeScale = 0;
                    pc.app.timeScale = (this.settings.timeScale + 1);
                    this.hooks.network.app.fire("Chat:Message", "Client", "Timescale - " + (this.settings.timeScale + 1) + "x", !0)
                    break;
                case 36: // Numpad7
                    this.settings.turboshoot = !this.settings.turboshoot;
                    this.hooks.network.app.fire("Chat:Message", "Client", "Turboshoot - " + (this.settings.turboshoot?"True":"False"), !0)
                    break;
                case 38: // Numpad8
                    this.settings.noAbcooldown = !this.settings.noAbcooldown;
                    this.hooks.network.app.fire("Chat:Message", "Client", "No Ability Cooldown - " + (this.settings.noAbcooldown?"True":"False"), !0)
                    break;
                case 45: // Numpad0
                    this.settings.rage = !this.settings.rage;
                    this.hooks.network.app.fire("Chat:Message", "Client", "Rage Mode - " + (this.settings.rage?"True":"False"), !0)
                    break;
                case 191: // SLASH
                    this.settings.noRecoil = !this.settings.noRecoil;
                    this.hooks.network.app.fire("Chat:Message", "Client", "No Recoil - " + (this.settings.noRecoil?"True":"False"), !0)
                    break;
                default: return;
            }
		});
	};

	this.waitForProp = async function(val) {
		while(!window.hasOwnProperty(val))
			await new Promise(resolve => setTimeout(resolve, 1000));
	};

	this.hookMovement = function() {
		const update = Movement.prototype.update;
        var defaultSpeeds = [];
		Movement.prototype.update = function (t) {
			if (!FakeGuard.hooks.movement) {
				FakeGuard.hooks.movement = this;
                defaultSpeeds = [this.defaultSpeed, this.strafingSpeed];
			}
			FakeGuard.onTick();
			update.apply(this, [t]);
			if (FakeGuard.settings.infAmmo) {
                this.setAmmoFull();
				this.isHitting = false;
			}
			if (FakeGuard.settings.infJump) {
				this.isLanded = true;
				this.bounceJumpTime = 0;
				this.isJumping = false;
			}
            if (FakeGuard.settings.turboshoot) {
                this.isShooting = false;

            }
            if (FakeGuard.settings.noAbcooldown) {
                this.playerCooldown = 0;
                this.lastThrowDate = 0;
            }
            if (FakeGuard.settings.noRecoil) {
                this.currentWeapon.cameraShake = 0;
                this.currentWeapon.spread = 0;

            }
            if (FakeGuard.settings.rage) {
                this.playerCooldown = 0;
                this.lastThrowDate = 0;
                this.isShooting = false;
                this.currentWeapon.spread = 0;
                this.isLanded = true;
				this.bounceJumpTime = 0;
				this.isJumping = false;
                this.setAmmoFull();
				this.isHitting = false;
                this.currentWeapon.cameraShake = 0;
            }

            this.defaultSpeed = defaultSpeeds[0] * (FakeGuard.settings.speedMlt + 1);
            this.strafingSpeed = defaultSpeeds[1] * (FakeGuard.settings.speedMlt + 1);
		};
		console.log("Movement Hooked");
	};

	this.hookNetwork = function() {
		var manager = NetworkManager.prototype.initialize;
		NetworkManager.prototype.initialize = function() {
			if (!FakeGuard.hooks.network) {
			   FakeGuard.hooks.network = this;
			}
			manager.call(this);
		};

		var ogRespawn = NetworkManager.prototype.respawn;
		NetworkManager.prototype.respawn = function(e) {
			ogRespawn.apply(this, [e]);
			if (e && e.length > 0 && FakeGuard.settings.autoKill) {
				var t = e[0], i = this.getPlayerById(t);
				if (i&& t!=this.playerid) {
                    var scope = this;
                    setTimeout(function() {
                        scope.send(["da", t, 100, 1, i.position.x, i.position.y, i.position.z])
                    }, 3500);
				}
			}
		}
		console.log("Network Hooked");
	};

	this.hookAnticheat = function() {
		VengeGuard.prototype.onCheck = function() {
			this.app.fire("Network:Guard", 1)
		}
		console.log("Anticheat Hooked");
	};

	this.hookLabel = function() {
        Label.prototype.update = function(t) {
            if (!pc.isSpectator) {
                if (this.player.isDeath)
                    return this.labelEntity.enabled = !1,
                        !1;
                if (Date.now() - this.player.lastDamage > 1800 && !FakeGuard.settings.esp)
                    return this.labelEntity.enabled = !1,
                        !1
            }
            var e = new pc.Vec3
            , i = this.currentCamera
            , a = this.app.graphicsDevice.maxPixelRatio
            , s = this.screenEntity.screen.scale
            , n = this.app.graphicsDevice;
            i.worldToScreen(this.headPoint.getPosition(), e),
                e.x *= a,
                e.y *= a,
                e.x > 0 && e.x < this.app.graphicsDevice.width && e.y > 0 && e.y < this.app.graphicsDevice.height && e.z > 0 ? (this.labelEntity.setLocalPosition(e.x / s, (n.height - e.y) / s, 0),
                                                                                                                                this.labelEntity.enabled = !0) : this.labelEntity.enabled = !1
        }
		console.log("Label Hooked");
	};

	this.onTick = function() {
        if (FakeGuard.settings.aimbot) {
			var closest;
			var rec;

			var players = FakeGuard.hooks.network.players;
			for (var i = 0; i < players.length; i++) {
				var target = players[i];
				var t = FakeGuard.hooks.movement.entity.getPosition();
				let calcDist = Math.sqrt( (target.position.y-t.y)**2 + (target.position.x-t.x)**2 + (target.position.z-t.z)**2 );
				if (calcDist < rec || !rec) {
					closest = target;
					rec = calcDist;
				}
			}

			FakeGuard.closestp = closest;
			let rayCastList = pc.app.systems.rigidbody.raycastAll(FakeGuard.hooks.movement.entity.getPosition(), FakeGuard.closestp.getPosition()).map(x=>x.entity.tags._list.toString())
			let rayCastCheck = rayCastList.length === 1 && rayCastList[0] === "Player";
			if (closest && rayCastCheck) {
				t = FakeGuard.hooks.movement.entity.getPosition()
					, e = Utils.lookAt(closest.position.x, closest.position.z, t.x, t.z);
				FakeGuard.hooks.movement.lookX = e * 57.29577951308232 + Math.random()/10 - Math.random()/10;
				FakeGuard.hooks.movement.lookY = -1 * (this.getXDire(closest.position.x, closest.position.y, closest.position.z, t.x, t.y+0.9, t.z)) * 57.29577951308232;
				FakeGuard.hooks.movement.leftMouse = true;
				FakeGuard.hooks.movement.setShooting(FakeGuard.hooks.movement.lastDelta);
			} else {
			   FakeGuard.hooks.movement.leftMouse = false;
			}
		}
	};

	this.getD3D = function(a, b, c, d, e, f) {
		let g = a - d, h = b - e, i = c - f;
		return Math.sqrt(g * g + h * h + i * i);
	};
	this.getXDire = function(a, b, c, d, e, f) {
		let g = Math.abs(b - e), h = this.getD3D(a, b, c, d, e, f);
		return Math.asin(g / h) * (b > e ? -1 : 1);
	};

	this.setupHooks();
	this.setupBinds();
};
FakeGuard = new(Hack)();

window.NetworkManager.prototype.kick = new Proxy(window.NetworkManager.prototype.kick, {
            apply(target, that, [type]) {
                console.log("Blocked Kick ",type[0])
            }
        })
