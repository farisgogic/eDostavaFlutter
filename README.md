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

4. Otvoriti konzolu

    ```
    docker pull rabbitmq:3-management
    ```
    ```
    docker run -d -p 15672:15672 -p 5672:5672 --name rabbit-test-for-medium rabbitmq:3-management
    ```
    
5. Otvoriti edostavamobile folder

    ```
    cd edostavamobile
    ```

6. Dohvatanje dependecy-a

    ```
    flutter pub get
    ```
    
7. Pokretanje mobilne aplikacije

    ```
    flutter run
    ```   

8. Otvoriti edostavaadmin folder

    ```
    cd edostavaadmin
    ```

9. Dohvatanje dependecy-a

    ```
    flutter pub get
    ```
    
10. Pokretanje mobilne aplikacije

    ```
    flutter run
    ```   
    
11. Pokretanje desktop aplikacije

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
    Korisnicko ime: kupac
    Lozinka: kupac  
    ```
    
    ```
    Korisnicko ime: proba
    Lozinka: proba  
    ```
    
    
- Dostavljac

    ```
    Korisnicko ime: dostavljac
    Lozinka: dostavljac  
    ```   
    
    ```
    Korisnicko ime: test
    Lozinka: test  
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
