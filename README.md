# KLOPA - Aplikacija za dostavu hrane

Aplikacija KLOPA je projekat rađen kao seminarski rad za predmet Razvoj softvera 2. Ova aplikacija omogućava dostavu hrane i pruža funkcionalnosti za 3 tipa korisnika: Uposlenike poslovnica, Dostavljače i Kupce. Uposlenici poslovnica koriste desktop aplikaciju, dok Dostavljači i Kupci koriste mobilnu aplikaciju.

## Tehnologije

- Backend: C#, .NET 6.0
- Desktop aplikacija (Uposlenici poslovnica): Flutter
- Mobilna aplikacija (Dostavljači i Kupci): Flutter

## Upute za instalaciju

1. Klonirajne GitHub repozitorija.

    ```
    git clone https://github.com/farisgogic/eDostavaFlutter.git
    ```
    
2. Otvoriti klonirani repozitoriji u konzoli

3. Pokretanje dokerizovanog API-ja i DB-a

    ```
    docker-compose up --build
    ```
    
4. Otvoriti edostavamobile folder

    ```
    cd edostavamobile
    ```

5. Dohvatanje dependecy-a

    ```
    flutter pub get
    ```
    
6. Pokretanje mobilne aplikacije

    ```
    flutter run
    ```   

7. Otvoriti edostavaadmin folder

    ```
    cd edostavaadmin
    ```

8. Dohvatanje dependecy-a

    ```
    flutter pub get
    ```
    
9. Pokretanje mobilne aplikacije

    ```
    flutter run
    ```   
    
10. Pokretanje desktop aplikacije

    ```
    1. Otvoriti solution u Visual Studiu 2022
    2. Desni klik na solution
    3. Configure Startup Projects
    4. Multiple startup projects
    5. eDostava - Start
    6. eDostava.Subscriber - Start
    7. OK
    8. CTRL + F5
    ```    
   
## Kredencijali za prijavu   

### Desktop aplikacija

- Uposlenik

    ```
    Korisnicko ime: Intermezzo
    Lozinka: Intermezzo
    ```

    ```
    Korisnicko ime: Divan
    Lozinka: Divan
    ``` 

    ```
    Korisnicko ime: Kula
    Lozinka: Kula
    ```     
    
### Mobilna aplikacija

- Kupac

    ```
    Korisnicko ime: faris
    Lozinka: faris
    ```
    
    ```
    Korisnicko ime: tarik
    Lozinka: tarik
    ```
    
    
- Dostavljac

    ```
    Korisnicko ime: aner
    Lozinka: aner
    ```   
    
    ```
    Korisnicko ime: fare
    Lozinka: fare
    ```
    
## KARTICA ZA NARUDŽBU

```
Broj kartice: 4242 4242 4242 4242
```

## NAPOMENA
Prilikom testiranja aplikacije, molimo Vas da koristite kupca s korisničkim imenom "kupac" kako biste mogli proaktivno evaluirati funkcionalnost slanja e-mail poruka nakon uspešne narudžbe.

## E-mail

```
E-mail: edostavatest@gmail.com
Lozinka: Razvojsoftvera2!  
```
