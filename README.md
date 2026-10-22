# Äijäareena

Godot 4.5 -projekti. Korjaukset ja testit on tarkistettu Godot 4.5.1:llä.
Käynnistä projekti normaalisti (F5): aloitusscene on `Views/main_menu.tscn`.

## Ohjaimet

Peli käyttää enintään neljää peliohjainta.

- Hahmonvalinta: A liittyy, A vahvistaa valinnan, ristiohjain vaihtaa hahmoa, B poistuu.
  Kun kaikki ovat valmiina, uusi A-painallus aloittaa pelin.
- Vasen tatti liikuttaa, oikea tatti kääntää ja tähtää.
- A hyppää, Y käyttää lähellä olevaa kohdetta.
- LB/RB poimii tai pudottaa vasemman/oikean käden esineen.
- LT/RT käyttää vasemman/oikean käden asetta.
- Back/View aloittaa seuraavan aallon. Start tai P avaa taukovalikon.
- Escape sulkee pelin.

## Grafiikka

Oletus on Balanced, MSAA 2× ja enintään 20 ragdollia. Asetukset säilyvät
saman pelikerran aikana, myös päävalikkoon palattaessa.

| Asetus | Käyttäytyminen |
| --- | --- |
| Low | 75 % 3D-renderöintiresoluutio; SSR, SSIL, SSAO ja volumetrinen sumu pois |
| Balanced | Täysi resoluutio; SSAO ja sumu käytössä, SSR ja SSIL pois |
| High | Täysi resoluutio ja alkuperäiset neljä efektiä käytössä |

Reunojenpehmennys valitaan erikseen. FXAA-valinta myös kytkee FXAA:n päälle.
Katuvalojen vaikutus spawnaamiseen on sama kaikilla grafiikka-asetuksilla.

## Tarkistukset

Korvaa `godot` oman Godot-suoritettavasi polulla:

```powershell
godot --headless --path . --fixed-fps 60 --script res://tests/gameplay_regression.gd --quit-after 2400
godot --headless --path . --fixed-fps 60 --script res://tests/ragdoll_transition.gd --quit-after 300
godot --headless --path . --fixed-fps 60 --script res://tests/performance_probe.gd
```

Pelitoimintojen testi tulostaa `REGRESSION: PASS`. Suorituskykykoe luo 60
zombia ja mittaa luonnin, ruutuajat sekä node-määrät ennen ja jälkeen kuolemien.
Rendererin kanssa koe tallentaa myös kuvat `.godot/probe-*.png`-tiedostoihin.
Ragdoll-vaihdon testi tarkistaa kaikkien 21 luun asennon ensimmäisellä
näkyvällä ruudulla kolmessa animaation vaiheessa. Rendererillä ajettuna se
tallentaa myös vaihtoa edeltävän kuvan ja kolme ensimmäistä ruutua vaihdon jälkeen.

Katso suorituskyvyn löydökset ja vertailutiedot tiedostosta [PERFORMANCE.md](PERFORMANCE.md).
