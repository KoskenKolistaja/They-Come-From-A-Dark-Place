# Suorituskyvyn ja toimintavirheiden viimeistely

Tarkistettu 22.–23.10.2026 Godot 4.5.1:llä, Forward+-rendererillä ja NVIDIA RTX 2060:llä.
Alkuperäinen vertailuversio on commit `e0c8649` (Game migration).

## Löydökset ja korjaukset

- Jokainen elävä zombie sisälsi myös piilotetun ragdollin luurankoineen ja
  fysiikkaluineen. Myös koiralla oli kaksi täydellistä mallia. Ruumiit luodaan
  nyt vasta kuollessa. Kuolleen vihollisen tekoäly ja ajastimet poistuvat heti.
- Kuolemankäsittely saattoi käynnistyä monta kertaa samalle kohteelle, ja
  zombie yritti lisätä jo toisen noden omistaman ruumiin sceneen. Kuolema ja
  rahapalkinto käsitellään kerran. Zombit ja koirat jakavat ragdoll-rajan;
  ruumis poistuu viimeistään 12 sekunnin jälkeen.
  Osumien jatkosäädössä zombin massa nostettiin 13 kg:sta 80 kg:aan ja
  koiran 24 kg:sta 36 kg:aan jakamalla massa kehonosien mukaan.
  Aseiden impulssiarvot säilyivät ennallaan. Räjähdykselle lisättiin
  säädettävä noste (`upward_bias`, oletus 0,35) ja suoran fysiikkaosuman
  impulssipiste korjattiin suhteelliseksi siirtymäksi.
  Kuolinhetken T-pose-välähdys korjattiin siirtämällä kaikki 21 luuta
  animaation asennosta ragdolliin ennen fysiikan käynnistämistä ja näyttämistä.
  Siirto huomioi luurankojen erilaiset lepoasennot ja mittakaavat.
- Spawnpisteiden 12 SubViewportia sekä `get_image()`-kuvanluku poistettiin
  aktiivisesta spawnausketjusta. Kuvanluku synkronoi CPU:n ja GPU:n, eikä
  vanha toteutus odottanut pyydetyn ruudun valmistumista. Katuvalojen
  sekä pelaajan ja kentän muiden paikallisten valojen suoja tarkistetaan
  nyt valon tilavuudesta ja fysiikan sädetestillä; seinät
  katkaisevat valon ja grafiikka-asetukset eivät muuta pelisääntöä.
- Spawner käynnistyi päiväsaikaan, käytti sovelluksen kokonaisaikaa ja
  jakoi viimeisen vihollisen jälkeen nollalla. Se toimii nyt vain aallon
  aikana ja käyttää tauotettavaa peliaikaa. Puuttuvat, valaistut tai varatut
  pisteet eivät kuluta vihollisia; uusi yritys tehdään 0,25 s kuluttua.
- Eläviä vihollisia on oletuksena enintään 80 kerrallaan. Loput odottavat
  jonossa aallon määräajan puitteissa. Rajaa voi säätää EnemySpawnerin
  `max_active_enemies`-ominaisuudesta. Aalto kestää edelleen 206 s.
- Luodinreiät elivät 60 sekuntia ilman määrärajaa. Niitä on nyt enintään
  96 ja yksittäisen reiän elinaika on 20 s. Lyhyiden efektien ajastimet
  kuuluvat niiden nodeille, joten ne siivotaan myös sceneä vaihdettaessa.
- MSAA 8× sekä SSR, SSIL, SSAO ja volumetrinen sumu olivat yhtä aikaa
  käytössä. Oletus on nyt Balanced ja MSAA 2×; alkuperäiset efektit saa
  takaisin High-asetuksella ja pehmennyksen omasta valikostaan.

Muita korjauksia: ohjaintunnusten ja liittymisjärjestyksen käsittely,
pelaajien erilliset aloituspaikat, hahmon alustuksen ajoitus, tyhjän käden
tarkistukset, kertaluonteinen katuvalomaksu, rakettipuhelimen oikea ammusmäärä,
taukovalikon sulkeminen, elvytys, uuden pelin tilan nollaus ja myöhäisten
aaltojen taulukkorajojen käsittely. Koirat ja heavytaurit poistuvat nyt myös
aallon lopussa. Heavytaur vaihtaa kohdetta, käyttää painovoimaa ja tekee
lähietäisyydellä 20 vahinkoa enintään 1,5 sekunnin välein.

Raketti tekee liikkeensä yli sädetestin, jotta se ei ohita ohutta seinää,
ja räjähtää vain kerran. Liike ja ammusefektit käyttävät delta-aikaa.
Tykkitorni, sen laatikko, käsiversio ja hologrammi poistettiin.

## Mittaukset

Sama testi käyttää satunnaissiementä 42, luo 60 zombia ja mittaa 180
fysiikkaruudun aikaväliä 30 ruudun lämmittelyn jälkeen. Spawner on tämän
vertailun aikana pysäytetty ja pelaajan kuolema estetty. Mittaukset ovat
yksittäisten ajojen havaintoja, eivät kaikkien kenttien tai koneiden FPS-lupaus.

| Mittaus | Alkuperäinen | Korjattu |
| --- | ---: | ---: |
| 60 zombin luonti, headless | 45,0 ms | 25,0 ms |
| Fysiikkaruutujen aikavälin mediaani, headless | 6,45 ms | 4,32 ms |
| Nodeja 60 elävän zombin kanssa | 4 620 | 2 519 |
| Renderöity koe, ruutuvälin mediaani | 11,42 ms | 7,93 ms |
| GPU-ajan mediaani | 3,08 ms | 2,11 ms |
| Kaikki katuvalot päällä, ruutuvälin mediaani | 11,75 ms | 9,20 ms |
| Kaikki katuvalot päällä, GPU-ajan mediaani | 3,54 ms | 2,83 ms |

Renderöinti: Vulkan Forward+, 960 × 540, VSync pois. Alkuperäisessä olivat
MSAA 8× ja kaikki alkuperäiset efektit; korjatussa Balanced ja MSAA 2×.
GPU-erot sisältävät siten myös grafiikan oletusasetusten muutoksen.
Headless-koe ei mittaa GPU-renderöintiä. Joltin aktiivisten objektien laskuri
palautti tässä versiossa nollaa, joten sitä ei käytetty tulosten arviointiin.
Täyden ruudun suurempi resoluutio ja ensimmäinen shaderien käännös voivat
antaa eri tulokset.

## Toistaminen

```powershell
# CPU- ja scene-kuormitus:
godot --headless --path . --fixed-fps 60 --script res://tests/performance_probe.gd

# GPU-koe (avaa ikkunan; sulkeutuu automaattisesti):
godot --path . --resolution 960x540 --disable-vsync --fixed-fps 60 --script res://tests/performance_probe.gd

# Sama kaikki katuvalot päällä:
godot --path . --resolution 960x540 --disable-vsync --fixed-fps 60 --script res://tests/performance_probe.gd -- --lights-on
```

Koe tallentaa asetusten, elävien vihollisten ja ragdollien kuvat
`.godot/probe-settings.png`, `.godot/probe-alive.png` ja `.godot/probe-dead.png`.
Kuvien tallennus tapahtuu mittausosuuden ulkopuolella.

Pelitoimintojen regressiotestissä on 38 tarkistusta, muun muassa ohjaimet,
valokeila ja seinän peitto, estetty spawnaus, viimeinen vihollinen, määräraja,
tauko, kuoleman kertaluonteisuus, ragdollien siivous, dekaaliraja, raketin
törmäys, elvytys ja päävalikkoon paluu. Testit eivät korvaa pitkää
pelitestausta oikeilla ohjaimilla tai tasapainotusta myöhäisissä aalloissa.
