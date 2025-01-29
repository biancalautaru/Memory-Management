***Nota: 8/10***

# [Tema laborator 2024.pdf](https://github.com/user-attachments/files/18274686/Tema.laborator.2024.pdf)

## Formularea temei

Pentru implementarea acestei teme, presupunem ca faceti parte din echipa de dezvoltare a unui sistem
de operare minimal - sistemul de operare fiind un produs software care se ocupa cu gestionarea si
coordonarea activitatilor unui sistem de calcul, cu rol in medierea accesului programelor de aplicatie
la resursele masinii. Sarcina care va revine este aceea de a implementa o componenta de gestiune
a dispozitivului de stocare (hard-disk ori SSD), iar pentru ca proiectul este abia la inceput, avem
multe presupuneri care simplifica dezvoltarea acestui produs.

## Implementarea sistemului cu memorie unidimensionala

In acest caz unidimensional, modul in care vi se cere sa functioneze dispozitivul de stocare este
urmatorul:

- capacitatea de stocare a dispozitivului este data si fixata la 8MB;
- capacitatea de stocare a dispozitivului este impartita in blocuri de cate 8kB fiecare;
- intr-un bloc poate fi stocat continut dintr-un singur fisier;
- un fisier are nevoie de cel putin doua blocuri pentru stocare;
- se presupune ca un fisier stocat este stocat contiguu;
- daca un fisier nu se poate stoca contiguu atunci scrierea sa pe dispozitiv nu este posibila.

Sistemul de operare nu are o structura de directoare si fisiere, ci doar trebuie sa stocheze fisiere.
In acest sens, fiecare fisier este identificat printr-un descriptor - ID unic (un numar natural intre 1
si 255); astfel, sistemul nostru poate stoca maximum 255 de fisiere diferite.

Ne intereseaza ca modulul de management al dispozitivului de stocare sa poate realiza urmatoarele
operatii:

- dat un descriptor (ID de fisier), sa se returneze intervalul de blocuri (start, end) unde este
stocat fisierul;
- dat un descriptor de fisier si dimensiunea sa in kB, sa se returneze intervalul de blocuri unde
poate sa fie stocat fisierul. Se va returna primul interval liber, in parcurgerea de la stanga la
dreapta. In cazul in care stocarea nu este posibila, se returneaza intervalul (0, 0);
- dat un descriptor, sa se stearga fisierul respectiv (adica sa se elibereze blocurile unde continutul
fisierul a fost salvat); consideram stergere operatia prin care blocurile primesc drept descriptor
valoarea 0;
- operatia de defragmentare: reordonati/recalculati blocurile in care sunt stocate fisierele, astfel
incat acestea sa fie stocate compact (adica incepand cu blocul 0 si folosind toate blocurile
consecutive, fara goluri).

## Implementarea sistemului cu memorie bidimensionala

Dupa ce ati finalizat implementarea in cazul unidimensional, observati ca spatiul pe care il aveti se
umple destul de repede, asa ca va ganditi la o extindere naturala, pe doua dimensiuni de aceasta
data, cu o dimensiune de 8MB in ambele sensuri. Astfel, presupunem acum ca dispozitivul de stocare
este bidimensional, adica avem o matrice de blocuri, iar o sectiune contigua este considerata pe linii.

- dat un descriptor de fisier, sa se returneze intervalul de blocuri ((startX, startY), (endX,
endY)) unde este stocat fisierul;
- dat un descriptor de fisier si dimensiunea sa in kB, sa se returneze ID-urile blocurilor unde
poate sa fie stocat fisierul. Se va intoarce primul interval in care fisierul poate fi pozitionat.
Daca nu se poate stoca atunci se returneaza intervalul ((0,0), (0,0))
- dat un descriptor de fisier, sa se stearga fisierul respectiv (adica sa se elibereze blocurile unde
continutul fisierului a fost salvat); exact ca in cazul unidimensional, consideram stergere operatia
prin care blocurile primesc drept descriptor valoarea 0;
- operatia de defragmentare bidimensionala; reordonati blocurile in care sunt stocate fisierele,
astfel incat acestea sa fie stocate compact in matrice (mutam golurile in dreapta-jos in matrice).
