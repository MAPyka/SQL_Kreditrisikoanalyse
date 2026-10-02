
#für das abschlussprojekt ein schema erstellt
create database if not exists finanzdienstleisterdb;

use finanzdienstleisterdb;


#vorgegebene csv datei hochgeladen per table data import wizard
#habe beim ersten hochladen der csv datei mich verschrieben bei der benennung der tabelle, deswegen lösche ich diese und lade sie erneut hoch

drop table crcredit_risk_dataset;


#überprüfung des datensatzes der vollständigkeit

select count(*) as anzahl_datensätze from credit_risk_dataset;
#erhalte 28638 datensätze
#über den editor erhalte ich 32582 zeilen inklusive kopfzeile
#suche nach dem fehler bei dem import, habe den import über den wizard schritt für schritt wiederholt, bekomme das gleiche ergebnis
#arbeite mit den vorlesungsfolien zusammen und importiere die daten mit dem dort stehenden weg
#dementsprechend lösche ich die vorhandene tabelle wieder

drop table credit_risk_dataset;

#erstelle die tabelle

create table if not exists credit_risk_dataset (
person_age int,
persone_income int,
person_home_ownership varchar(20),
person_emp_length decimal(5,2),
loan_intent varchar(50),
loan_grade varchar(10),
loan_amnt int,
loan_int_rate decimal(5,2),
loan_status tinyint,
loan_percent_income decimal(5,4),
cb_person_default_on_file varchar(10),
cb_person_cred_hist_length int
);


#speicherort für die eingabedatei anzeigen lassen

select @@secure_file_priv;


#import der csv datei

load data infile "D:\MySQL\Data_MySQL Server 26.7\Uploads"
into table credit_risk_dataset
fields terminated by ","
lines terminated by "\n"
ignore 1 rows;

#error code 1290 -> The MySQL server is running with the --secure-file-priv option so it cannot execute this statement
#stelle die sicherheit um für diesen befehl und führe diesen erneut aus
#suche freigegeben pfad raus

show variables like "secure_file_priv";

#habe ein "\" vergessen mitzunehmen und den dateinamen
#führe den befehl erneut aus

load data infile "D:\MySQL\Data_MySQL Server 26.7\Uploads\credit_risk_dataset.csv"
into table credit_risk_dataset
fields terminated by ","
optionally enclosed by """"
lines terminated by "\r\n"
ignore 1 rows;

#fehler taucht erneut auf
#weitere fehlersuche

show variables like "local_infile";

#local_infile ist off, schalte es ein

set global local_infile = 1;

show variables like "local_infile";


#neuer versuch den import auszuführen

load data local infile "D:\MySQL\Data_MySQL Server 26.7\Uploads\credit_risk_dataset.csv"
into table credit_risk_dataset
fields terminated by ","
optionally enclosed by """"
lines terminated by "\r\n"
ignore 1 rows;

#erneuter fehler code 2068
#versuche "/" anstatt "\" zu verwenden

load data infile "D:/MySQL/Data_MySQL Server 26.7/Uploads/credit_risk_dataset.csv"
into table credit_risk_dataset
fields terminated by ","
optionally enclosed by """"
lines terminated by "\r\n"
ignore 1 rows;

#nun Error Code: 1366. Incorrect decimal value: '' for column 'loan_int_rate' at row 40
#ändere nun den import befehl

describe credit_risk_dataset;


load data infile "D:/MySQL/Data_MySQL Server 26.7/Uploads/credit_risk_dataset.csv"
into table credit_risk_dataset
fields terminated by ","
optionally enclosed by """"
lines terminated by "\r\n"
ignore 1 rows
(
person_age,
person_income,
person_home_ownership,
person_emp_length,
loan_intent,
loan_grade,
loan_amnt,
loan_int_rate,
loan_status,
loan_percent_income,
cb_person_default_on_file,
cb_person_cred_hist_length
)
set loan_int_rate = nullif(loan_int_rate, " ");

#funktioniert nicht weil ich mich bei der erstellung der tabelle verschrieben habe, ich ändere erst die tabelle

alter table credit_risk_dataset
rename column persone_income to person_income;


#nun erneut load data infile

load data infile "D:/MySQL/Data_MySQL Server 26.7/Uploads/credit_risk_dataset.csv"
into table credit_risk_dataset
fields terminated by ","
optionally enclosed by """"
lines terminated by "\r\n"
ignore 1 rows
(
person_age,
person_income,
person_home_ownership,
person_emp_length,
loan_intent,
loan_grade,
loan_amnt,
loan_int_rate,
loan_status,
loan_percent_income,
cb_person_default_on_file,
cb_person_cred_hist_length
)
set loan_int_rate = nullif(loan_int_rate, " ");

#fehler: Error Code: 1292. Truncated incorrect DECIMAL value: ' '
#ändere befehl mit trim

load data infile "D:/MySQL/Data_MySQL Server 26.7/Uploads/credit_risk_dataset.csv"
into table credit_risk_dataset
fields terminated by ","
optionally enclosed by """"
lines terminated by "\r\n"
ignore 1 rows
(
person_age,
person_income,
person_home_ownership,
person_emp_length,
loan_intent,
loan_grade,
loan_amnt,
@loan_int_rate,
loan_status,
loan_percent_income,
cb_person_default_on_file,
cb_person_cred_hist_length
)
set loan_int_rate = nullif(trim(@loan_int_rate), "");

#wieder fehler Error Code: 1366. Incorrect decimal value: '' for column 'person_emp_length' at row 106
#ändere den code erneut

truncate table credit_risk_dataset;

load data infile
"d:/mysql/data_mysql server 26.7/uploads/credit_risk_dataset.csv"
into table credit_risk_dataset
fields terminated by ","
optionally enclosed by """"
lines terminated by "\r\n"
ignore 1 rows
(
@person_age,
@person_income,
person_home_ownership,
@person_emp_length,
loan_intent,
loan_grade,
@loan_amnt,
@loan_int_rate,
@loan_status,
@loan_percent_income,
cb_person_default_on_file,
@cb_person_cred_hist_length
)
set
person_age = nullif(trim(@person_age), ""),
person_income = nullif(trim(@person_income), ""),
person_emp_length = nullif(trim(@person_emp_length), ""),
loan_amnt = nullif(trim(@loan_amnt), ""),
loan_int_rate = nullif(trim(@loan_int_rate), ""),
loan_status = nullif(trim(@loan_status), ""),
loan_percent_income = nullif(trim(@loan_percent_income), ""),
cb_person_cred_hist_length = nullif(trim(@cb_person_cred_hist_length), "");
    
select count(*) from credit_risk_dataset;

#final hat er nun die datei mit 32581 datensätzen hochgeladen

#kontrolle wo fehlende daten vorhanden sind

select
count(*) - count(person_age) as person_age_null,
count(*) - count(person_income) as person_income_null,
count(*) - count(person_home_ownership) as person_home_ownership_null,
count(*) - count(person_emp_length) as person_emp_length_null,
count(*) - count(loan_intent) as loan_intent_null,
count(*) - count(loan_grade) as loan_grade_null,
count(*) - count(loan_amnt) as loan_amnt_null,
count(*) - count(loan_int_rate) as loan_int_rate_null,
count(*) - count(loan_status) as loan_status_null,
count(*) - count(loan_percent_income) as loan_percent_income_null,
count(*) - count(cb_person_default_on_file) as cb_person_default_on_file_null,
count(*) - count(cb_person_cred_hist_length) as cb_person_cred_hist_length_null
from credit_risk_dataset;

#person_emp_length_null ->895
#loan_int_rate_null ->3116
#alle andere werte ->0

#######################################################################

#gesamte tabelle analysieren

select * from credit_risk_dataset;

#füge dem datensatz eindeutige id hinzu

alter table credit_risk_dataset
add column id bigint auto_increment primary key first;

#erwarte bei der analyse anomalien
#ersetze eventuelle anomalien durch den wert "null", vorrausgesetzt es ist plausibel


#erste spalte person_age

select * from credit_risk_dataset order by person_age;
select * from credit_risk_dataset order by person_age desc;

#anomalie bei dem alter festgestellt, fünf personen identifiziert, datensätze zeigen plausibel dass das alter nicht passt
#alter größer als 122 auf null gesetzt
#id: 32256, 245, 349, 339, 556

update credit_risk_dataset
set person_age = null
where id = 32256;

update credit_risk_dataset
set person_age = null
where id = 245;

update credit_risk_dataset
set person_age = null
where id = 349;

update credit_risk_dataset
set person_age = null
where id = 339;

update credit_risk_dataset
set person_age = null
where id = 556;


#zweite spalte person_income

select * from credit_risk_dataset order by person_income;
select * from credit_risk_dataset order by person_income desc;

#auffällig sind die obersten neun id's mit dem höchsten einkommen


#dritte spalte person_home_ownership

select person_home_ownership,
count(*) as anzahl
from credit_risk_dataset
group by person_home_ownership
order by anzahl desc;

#ca. 50% der personen sind mieter

#vierte spalte person_emp_length

select * from credit_risk_dataset order by person_emp_length desc;

#zwei anomalien mit 123 jahren einstellung
#id's 1 & 450, setze die auf "null"

update credit_risk_dataset
set person_emp_length = null
where id in (1, 450);


#fünfte spalte loan_intent

select loan_intent,
count(*) as anzahl
from credit_risk_dataset
group by loan_intent
order by anzahl desc;

#fünf von sechs begründungen als anzahl liegen im ähnlichen bereich, homeimprovment liegt abgeschlagen als letzter


#sechste spalte loan_grade

select loan_grade,
count(*) as anzahl
from credit_risk_dataset
group by loan_grade
order by anzahl desc;

#etwa zwei drittel der kreditnehmer haben einen loan_grade von a oder b


select * from credit_risk_dataset;

#siebte spalte loan_amnt

select * from credit_risk_dataset order by loan_amnt;
select * from credit_risk_dataset order by loan_amnt desc;

#höchste loan_amnt 35.000, niedrigste 500


#achte spalte loan_int_rate

select * from credit_risk_dataset order by loan_int_rate;
select * from credit_risk_dataset order by loan_int_rate desc;

select loan_int_rate,
count(*) as anzahl
from credit_risk_dataset
group by loan_int_rate
order by anzahl desc;

#3116 "null" werte erhalten, der größte block

select count(distinct loan_int_rate) as anzahl_verschiedener_zinsraten
from credit_risk_dataset;

#es gibt 348 verschiedene loan_int_rate


#neunte spalte loan_status

select loan_status,
count(*) as anzahl
from credit_risk_dataset
group by loan_status
order by anzahl desc;

# etwa 20% der kredite sind ausgefallen


#zehnte spalte loan_percent_income

select * from credit_risk_dataset order by loan_percent_income;
select * from credit_risk_dataset order by loan_percent_income desc;

select loan_percent_income,
count(*) as anzahl
from credit_risk_dataset
group by loan_percent_income
order by anzahl desc;

#gruppiere loan_percent_income in fünf stufen

select
case
when loan_percent_income <= 0.10 then "sehr niedrig"
when loan_percent_income <= 0.20 then "niedrig"
when loan_percent_income <= 0.30 then "mittel"
when loan_percent_income <= 0.40 then "hoch"
else "sehr hoch"
end as einkommensbelastung,
count(*) as anzahl
from credit_risk_dataset
group by einkommensbelastung
order by anzahl desc;

#etwa zwei drittel liegen im niedrig oder sehr niedrig


#elfte spalte cb_person_default_on_file, y = kreditausfall, n = kein kreditausfall

select cb_person_default_on_file,
count(*) as anzahl
from credit_risk_dataset
group by cb_person_default_on_file
order by anzahl desc;


#zwölfte spalte cb_person_cred_hist_length

select * from credit_risk_dataset order by cb_person_cred_hist_length;
select * from credit_risk_dataset order by cb_person_cred_hist_length desc;

select cb_person_cred_hist_length,
count(*) as anzahl
from credit_risk_dataset
group by cb_person_cred_hist_length
order by anzahl desc;

#gruppiere cb_person_cred_hist_length in fünf teilen

select
case
when cb_person_cred_hist_length <= 2 then "sehr kurz"
when cb_person_cred_hist_length <= 5 then "kurz"
when cb_person_cred_hist_length <= 10 then "mittel"
when cb_person_cred_hist_length <= 15 then "lang"
else "sehr lang"
end as kredithistorie_gruppe,
count(*) as anzahl
from credit_risk_dataset
group by kredithistorie_gruppe
order by anzahl desc;

#etwa ein drittel haben eine kurze historie

#######################################################################

#analysen zu aufgabe 1
#insgesamt ausgefallene kredite nach loan_status

select loan_status,
count(*) as anzahl,
round(count(*) * 100.0 / (select count(*) from credit_risk_dataset), 0) as anteil_prozent
from credit_risk_dataset
group by loan_status;

#ausgefallene kredite 7108 entspricht 22%, erfolgreich zurück gezahlte kredite 25473 entspricht 78%

#ausfall nach loan_grade

select loan_grade,
count(*) as anzahl_kredite,
sum(loan_status) as ausfälle,
round(avg(loan_status) * 100, 0) as ausfallquote_prozent
from credit_risk_dataset
group by loan_grade
order by loan_grade;

#erkennbar ist klar, dass die ausfallquote deutlich steigt, je höher der loan_grade ist
#außerdem der sprung von grade c zu d ist groß, von 21% (etwa der durchschnitt der gesamtquote) zu 59%

#zusammenhang mit verwendungszweck überprüfen

select loan_intent,
count(*) as anzahl_kredite,
sum(loan_status) as ausfälle,
round(avg(loan_status) * 100, 2) as ausfallquote_prozent
from credit_risk_dataset
group by loan_intent
order by ausfallquote_prozent desc;

#debtconsolidation, medical, homeimprovement liegen über den schnitt der ausfallquote von 22%
#venture liegt mit 15% deutlich darunter


#kreditbelastung im verhältnis zum einkommen

select
case
when loan_percent_income <= 0.10 then "sehr niedrig"
when loan_percent_income <= 0.20 then "niedrig"
when loan_percent_income <= 0.30 then "mittel"
when loan_percent_income <= 0.40 then "hoch"
else "sehr hoch"
end as einkommensbelastung,
count(*) as anzahl
from credit_risk_dataset
group by einkommensbelastung
order by anzahl desc;

#wie oben bereits genannt sind etwa zwei drittel im niedrigerem belastungsbreich
#etwa ein zehntel sind im hochrisiko

#ausfallquote innerhalb der gruppen

select
case
when loan_percent_income < 0.10 then "sehr niedrig"
when loan_percent_income < 0.20 then "niedrig"
when loan_percent_income < 0.30 then "mittel"
when loan_percent_income < 0.40 then "hoch"
else "sehr hoch"
end as einkommensbelastung,
count(*) as anzahl_kredite,
sum(loan_status) as ausfälle,
round(avg(loan_status) * 100, 2) as ausfallquote_prozent
from credit_risk_dataset
group by einkommensbelastung
order by
case
when einkommensbelastung = "sehr niedrig" then 1
when einkommensbelastung = "niedrig" then 2
when einkommensbelastung = "mittel" then 3
when einkommensbelastung = "hoch" then 4
when einkommensbelastung = "sehr hoch" then 5
end;

#klare erkennung, je höher die einkommensbelastung, desto höher die ausfallquote
#auffällig der sprunghaftige anstieg von mittel 21% (durchschnitt) zu hoch 62%


#vergleich ausfallquote mit der vergangenheit der kreditnehmer

select cb_person_default_on_file,
count(*) as anzahl_kredite,
sum(loan_status) as ausfälle,
round(avg(loan_status) * 100, 2) as ausfallquote_prozent
from credit_risk_dataset
group by cb_person_default_on_file
order by ausfallquote_prozent desc;

#auffällig ist, kreditnehmer mit bereits notierten ausfall haben ein weit höhere ausfallquote mit 38%
#kreditnehmer ohne vermerk liegen unter dem durchschnitt (22%) bei 18%


#kreditlänge gegenüber der ausfallquote

select
case
when cb_person_cred_hist_length <= 2 then "sehr kurz"
when cb_person_cred_hist_length <= 5 then "kurz"
when cb_person_cred_hist_length <= 10 then "mittel"
when cb_person_cred_hist_length <= 15 then "lang"
else "sehr lang"
end as kredithistorie_gruppe,
count(*) as anzahl_kredite,
sum(loan_status) as ausfälle,
round(avg(loan_status) * 100, 2) as ausfallquote_prozent
from credit_risk_dataset
group by kredithistorie_gruppe
order by
case
when kredithistorie_gruppe = "sehr kurz" then 1
when kredithistorie_gruppe = "kurz" then 2
when kredithistorie_gruppe = "mittel" then 3
when kredithistorie_gruppe = "lang" then 4
when kredithistorie_gruppe = "sehr lang" then 5
end;

#die ausfallquoten liegen im bereich des durchschnitts
#keine nennenswerte auffälligkeiten


#ausfall nach kredithöhe, gruppiert in 5000er schritte

select
case
when loan_amnt < 5000 then "unter 5.000"
when loan_amnt < 10000 then "5.000 - 9.999"
when loan_amnt < 15000 then "10.000 - 14.999"
when loan_amnt < 20000 then "15.000 - 19.999"
when loan_amnt < 25000 then "20.000 - 24.999"
when loan_amnt < 30000 then "25.000 - 29.999"
else "30.000 - 35.000"
end as kreditklasse,
count(*) as anzahl_kredite,
sum(loan_status) as ausfälle,
round(avg(loan_status) * 100, 2) as ausfallquote_prozent
from credit_risk_dataset
group by kreditklasse
order by
case
when kreditklasse = "unter 5.000" then 1
when kreditklasse = "5.000 - 9.999" then 2
when kreditklasse = "10.000 - 14.999" then 3
when kreditklasse = "15.000 - 19.999" then 4
when kreditklasse = "20.000 - 24.999" then 5
when kreditklasse = "25.000 - 29.999" then 6
else 7
end;

#eine tendenz ist erkennbar, je höher der kredit, desto wahrscheinlicher die ausfallquote
#aber die anzahl der vergebenen kredite ist wesentlich geringer, je höher sie sind
#etwa ein viertel der kredite sind höher als 15000, erst da übersteigt die ausfallquote den durchschnitt

########################################################################

#zusammenfassung
#die analyse der spalten loan_grade, loan_percent_income und cb_person_default_on_file geben gute hinweise
#wiederum loan_amnt, loan_intent und cb_person_cred_hist_length eher weniger

#zur aufgabestellung einer kreditspezifische überwachung
#wäre ein drei stufiges überwachungsmodel möglich
#1.)niedrige überwachung mit loan_grade a-c, loan_percent_income unter 30% und kein bisheriger ausfall
#2.)mittlere überwachung mit loan_grade d, loan_amnt größer 15000
#3.)höhere überwachung mit loan_grade d oder schlechter, loan_percent_income >30% und vorheriger ausfall

#anhand der mögliche drei einstufungen eine zusammenfassung

select
case
when loan_percent_income >= 0.30
or loan_grade in ("e", "f", "g")
or cb_person_default_on_file = "y"
then "hohe überwachung"
when loan_grade = "d"
or loan_amnt >= 15000
or loan_intent in ("debtconsolidation", "medical", "homeimprovement")
then "mittlere überwachung"
else "niedrige überwachung"
end as überwachungsstufe,
count(*) as anzahl_kredite,
sum(loan_status) as ausfülle,
round(avg(loan_status) * 100, 2) as ausfallquote_prozent
from credit_risk_dataset
group by überwachungsstufe
order by
case
when überwachungsstufe = "niedrige überwachung" then 1
when überwachungsstufe = "mittlere überwachung" then 2
when überwachungsstufe = "hohe überwachung" then 3
end;

#die kreditüberwachung mit diesem drei stufigen model zeigt folgende ausfallquoten an
#1.)niedrige überwachung -> 7% 
#2.)mittlere überwachung -> 14%
#3.)hohe überwachung -> 48%

#######################################################################

#analysen zu aufgabe 2
#durchschnittlicher zinssatz je loan_grade mit ausfallquote

select
loan_grade,
count(*) as anzahl_kredite,
round(avg(loan_int_rate), 2) as durchschnittlicher_zins,
round(min(loan_int_rate), 2) as niedrigster_zins,
round(max(loan_int_rate), 2) as höchster_zins,
round(avg(loan_status) * 100, 2) as ausfallquote_prozent
from credit_risk_dataset
where loan_int_rate is not null
group by loan_grade
order by loan_grade;

#der zinssatz steigt im durchschnitt, je höher die loan_grade
#auffällig ist aber der konstante mindest zinssatz von 6% für loan_grade b bis e

#überprüfung wie oft niedrig zinsen an risikoklassen vergeben worden sind

select loan_grade,
count(*) as anzahl_kredite,
sum(case
when loan_int_rate <= 9.63 then 1
else 0
end) as kredite_mit_niedrigem_zins,
round(sum(case
when loan_int_rate <= 9.63 then 1
else 0
end) * 100.0 / count(*), 2) as anteil_niedriger_zins_prozent
from credit_risk_dataset
where loan_grade in ("c", "d", "e")
and loan_int_rate is not null
group by loan_grade
order by loan_grade;


#loan_grade und loan_amnt gegenüber stellen

select
loan_grade,
count(*) as anzahl_kredite,
round(avg(loan_amnt), 2) as durchschnittlicher_kreditbetrag,
min(loan_amnt) as niedrigster_kreditbetrag,
max(loan_amnt) as höchster_kreditbetrag,
round(avg(loan_percent_income) * 100, 2) as durchschnittliche_einkommensbelastung_prozent,
round(avg(loan_status) * 100, 2) as ausfallquote_prozent
from credit_risk_dataset
group by loan_grade
order by loan_grade;

#verlauf erkennbar
#durchschnittliche werte wie kreditbetrag, einkommensbelastung und ausfallquoten steigen an je höher der loan_grade
#d.h. kreditnehmer die eine höhere überwachung erhalten (d und aufwärts), erhalten gleichzeitig auch die höchsten kreditbeträge

#aus vorheriger analyse erkannt loan_amnt >= 15000 und loan_percent_income >=0.30 sind die ausfallquoten stark erkennbar
#diese grenzen gegenüberstellen

select loan_grade,
count(*) as anzahl_kredite,
sum(case
when loan_amnt >= 15000 then 1
else 0
end) as kredite_ab_15000,
round(sum(case
when loan_amnt >= 15000 then 1
else 0
end) * 100.0 / count(*), 2) as anteil_kredite_ab_15000_prozent,
sum(case
when loan_percent_income >= 0.30 then 1
else 0
end) as hohe_einkommensbelastung,
round(sum(case
when loan_percent_income >= 0.30 then 1
else 0
end) * 100.0 / count(*), 2) as anteil_hohe_einkommensbelastung_prozent,
sum(case
when loan_amnt >= 15000
and loan_percent_income >= 0.30
then 1
else 0
end) as hoher_kredit_und_hohe_belastung
from credit_risk_dataset
group by loan_grade
order by loan_grade;

#je höher der loan_grade (d und aufwärts) desto höher der anteil an hohen krediten und einkommensbelastung

#ausfallquote überprüfen von loan_amnt >=15000 und loan_percent_income >=0.30

select loan_grade,
count(*) as anzahl_kredite,
sum(loan_status) as ausfälle,
round(avg(loan_status) * 100, 2) as ausfallquote_prozent
from credit_risk_dataset
where loan_amnt >= 15000
and loan_percent_income >= 0.30
group by loan_grade
order by loan_grade;

#die verbindung zeigt deutlich dass bei allen loan_grade eine erhöhte ausfallquote exisitiert
#je höher die loan_grade, desto höher die ausfallquote

#zusammenfassung
#bei der zinsvergabe erscheinen keine nennenswerte auffälligkeiten
#die kombination bei der vergabe der kredithöhe mit der einkommensbelastung kann man klar erkennen, dass die ausfallquote sehr hoch ist, unabhängig der loan_grade
