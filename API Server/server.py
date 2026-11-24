#!/usr/bin/env python3
"""
Servidor API REST Mockup en Python per a "Misteris Urbans: Detectiu Contrarellotge".
Serveix missions aleatòries en format JSON per a consum des de Godot 3.6 LTS (HTTPRequest).
No requereix dependències externes (utilitza la llibreria estàndard http.server).
"""

import json
import os
import random
from http.server import HTTPServer, BaseHTTPRequestHandler

PORT = 8000
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
CASES_DIR = os.path.join(BASE_DIR, "data", "missions")
SUSPECTS_FILE = os.path.join(BASE_DIR, "data", "sospitosos_matrix.json")


class MissionAPIHandler(BaseHTTPRequestHandler):

    def _send_json_response(self, status_code: int, payload: dict):
        """Serialitza el diccionari a UTF-8, calcula el Content-Length i envia la resposta."""
        body_bytes = json.dumps(payload, ensure_ascii=False, indent=2).encode("utf-8")
        self.send_response(status_code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body_bytes)))
        self.send_header("Connection", "close")
        # Capçaleres CORS per permetre peticions des de qualsevol client (Godot / Web)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()
        self.wfile.write(body_bytes)

    def do_OPTIONS(self):
        # Respondre preflight CORS
        self.send_response(200)
        self.send_header("Content-Length", "0")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_GET(self):
        # Endpoint principal: GET /api/missio o GET /api/missio/aleatoria
        if self.path in ["/api/missio", "/api/missio/aleatoria", "/"]:
            self._handle_get_random_mission()
        elif self.path == "/api/sospitosos":
            self._handle_get_suspects()
        else:
            self._send_json_response(404, {
                "error": "Endpoint no disponible",
                "path": self.path
            })

    def _handle_get_random_mission(self):
        try:
            # Busquem els fitxers .json al directori de missions
            if not os.path.exists(CASES_DIR):
                mission_data = self._generate_fallback_mission()
            else:
                files = [f for f in os.listdir(CASES_DIR) if f.endswith(".json")]
                if files:
                    selected_file = random.choice(files)
                    file_path = os.path.join(CASES_DIR, selected_file)
                    with open(file_path, "r", encoding="utf-8") as f:
                        mission_data = json.load(f)
                else:
                    mission_data = self._generate_fallback_mission()

            self._send_json_response(200, mission_data)
            print(f"[API Python] Missió servida correctament: {mission_data.get('missio', {}).get('titol', 'Sense títol')}")

        except Exception as e:
            self._send_json_response(500, {
                "error": "Error intern del servidor",
                "detall": str(e)
            })

    def _handle_get_suspects(self):
        try:
            if os.path.exists(SUSPECTS_FILE):
                with open(SUSPECTS_FILE, "r", encoding="utf-8") as f:
                    data = json.load(f)
                self._send_json_response(200, data)
            else:
                self._send_json_response(404, {"error": "Matriu de sospitosos no trobada"})
        except Exception as e:
            self._send_json_response(500, {"error": str(e)})

    def _generate_fallback_mission(self):
        """Missió mockup generada dinàmicament si no hi ha fitxers al disc."""
        return {
            "missio": {
                "id": f"MIS-MOCK-{random.randint(100, 999)}",
                "titol": "El Misteri del Rellotge de la Ciutat",
                "descripcio": "El mecanisme del rellotge central ha sigut sabotejat. Troba les pistes, interroga als 8 testimonis i descobreix el culpable."
            },
            "resolucio": {
                "culpable_id": "SOSP-05",
                "lloc_ocultacio": "Est",
                "explicacio": "Eudald Puig (El Tenebrós) s'oculta al sector Est. El testimoni 3 mentia (deia que portava ulleres), com va revelar el testimoni 8."
            },
            "objectes_mapa": [
                {
                    "id": "OBJ-01",
                    "nom": "Ulleres UV",
                    "descripcio": "Permeten llegir missatges escrits amb tinta invisible."
                },
                {
                    "id": "OBJ-02",
                    "nom": "Lupa de Detectiu",
                    "descripcio": "Permet examinar empremtes dactilars i detalls fins."
                },
                {
                    "id": "OBJ-03",
                    "nom": "Decodificador",
                    "descripcio": "Traductor de claus i notes encriptades."
                }
            ],
            "testimonis": [
                {
                    "id": "TEST-01",
                    "nom": "Sr. Joan (Conserge)",
                    "posicio_spawn_id": 1,
                    "tipus_testimoni": "pista_caracteristica",
                    "objecte_requerit_id": None,
                    "missatge_sense_objecte": None,
                    "pista": {
                        "caracteristica": "barret",
                        "valor_afirmat": True,
                        "text": "Vaig veure fugir al sospitós i PORTAVA barret!"
                    }
                },
                {
                    "id": "TEST-02",
                    "nom": "Marta (Guàrdia)",
                    "posicio_spawn_id": 2,
                    "tipus_testimoni": "pista_caracteristica",
                    "objecte_requerit_id": "OBJ-01",
                    "missatge_sense_objecte": "Necessites les 'Ulleres UV' per a llegir la nota invisible.",
                    "pista": {
                        "caracteristica": "bigotis",
                        "valor_afirmat": True,
                        "text": "La nota invisible diu: 'El culpable portava un gran bigotis'."
                    }
                },
                {
                    "id": "TEST-03",
                    "nom": "Sr. Ricard (Informador)",
                    "posicio_spawn_id": 3,
                    "tipus_testimoni": "pista_caracteristica",
                    "objecte_requerit_id": None,
                    "missatge_sense_objecte": None,
                    "pista": {
                        "caracteristica": "ulleres",
                        "valor_afirmat": True,
                        "text": "El sospitós duia unes ulleres fosques."
                    }
                },
                {
                    "id": "TEST-04",
                    "nom": "Laura (Escombriaire)",
                    "posicio_spawn_id": 4,
                    "tipus_testimoni": "pista_caracteristica",
                    "objecte_requerit_id": "OBJ-02",
                    "missatge_sense_objecte": "Necessites la 'Lupa de Detectiu' per examinar la taca.",
                    "pista": {
                        "caracteristica": "cicatriu",
                        "valor_afirmat": False,
                        "text": "No hi havia marques ni cicatrius al rostre."
                    }
                },
                {
                    "id": "TEST-05",
                    "nom": "Taxista Nocturn",
                    "posicio_spawn_id": 5,
                    "tipus_testimoni": "sense_valor",
                    "objecte_requerit_id": None,
                    "missatge_sense_objecte": None,
                    "pista": {
                        "text": "La ciutat estava tranquil·la aquesta nit."
                    }
                },
                {
                    "id": "TEST-06",
                    "nom": "Venedor de Diaris",
                    "posicio_spawn_id": 6,
                    "tipus_testimoni": "sense_valor",
                    "objecte_requerit_id": None,
                    "missatge_sense_objecte": None,
                    "pista": {
                        "text": "Extra, extra! Misteri al centre urbà."
                    }
                },
                {
                    "id": "TEST-07",
                    "nom": "El Confident",
                    "posicio_spawn_id": 7,
                    "tipus_testimoni": "pista_ubicacio",
                    "objecte_requerit_id": "OBJ-03",
                    "missatge_sense_objecte": "Necessites el 'Decodificador' per traduir el missatge.",
                    "pista": {
                        "lugar": "Est",
                        "text": "Missatge traduït: 'El culpable s'amaga als magatzems del sector Est'."
                    }
                },
                {
                    "id": "TEST-08",
                    "nom": "El Xaman de la Ciutat",
                    "posicio_spawn_id": 8,
                    "tipus_testimoni": "pista_refutacio",
                    "objecte_requerit_id": None,
                    "missatge_sense_objecte": None,
                    "pista": {
                        "testigo_refutado_id": "TEST-03",
                        "text": "En Ricard (Testimoni 3) menteix! Va dir just el contrari de la veritat."
                    }
                }
            ]
        }


def run():
    server_address = ("", PORT)
    httpd = HTTPServer(server_address, MissionAPIHandler)
    print(f"Servidor API en marxa a http://localhost:{PORT}")
    print(f"Endpoint missions: http://localhost:{PORT}/api/missio")
    print(f"Endpoint sospitosos: http://localhost:{PORT}/api/sospitosos")
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nAturant el servidor...")
        httpd.server_close()


if __name__ == "__main__":
    run()