# Sistem preporuke poslova (Recommender)

## Pristup
HireMatch koristi content-based (sadrzajno zasnovan) sistem preporuke. Poslovi se preporucuju
kandidatu na osnovu poklapanja karakteristika posla sa profilom i preferencijama kandidata.
Sistem je explainable (objasnjiv) - uz svaku preporuku vraca se tekstualno objasnjenje zasto
je odredeni posao preporucen.

## Ulazni podaci (signali)
1. Preferirana industrija kandidata (CandidateProfile.PreferredIndustryId) - bira se na onboardingu, mijenja na profilu.
2. Preferirani tip zaposlenja (CandidateProfile.PreferredEmploymentTypeId).
3. Vjestine kandidata (UserSkills, many-to-many) - bira ih kandidat na profilu.

Svi podaci se unose kroz mobilnu aplikaciju i cuvaju u bazi.

## Algoritam bodovanja
Za svaki aktivni posao (ExpiryDate nije prosao) racuna se skor:

| Signal | Uslov | Bodovi |
|--------|-------|--------|
| Industrija | posao pripada preferiranoj industriji | +2 |
| Tip zaposlenja | posao odgovara preferiranom tipu rada | +1 |
| Vjestine | za svaku vjestinu kandidata koja se trazi na poslu | +1 po vjestini |

Konacni skor je zbir bodova. Poslovi sa skorom 0 se ne preporucuju.

## Objasnjive preporuke
Za svaki posao gradi se objasnjenje, npr:
"Preporuceno jer odgovara tvojoj industriji (IT); odgovara zeljenom tipu rada (Full-time); 2 vjestine se poklapaju (Angular, SQL Server)."

## Rangiranje
Rezultati se sortiraju opadajuce po skoru i vraca se najvise take poslova (podrazumijevano 10).

## Gdje se koristi
- Backend: JobPostEFService.GetRecommended(candidateId, take)
- Vraca listu RecommendedJobResponse (Id, Title, CompanyName, Location, EmploymentTypeName, Score, Explanation).
- Mobilna aplikacija prikazuje preporuke na pocetnom ekranu sa objasnjenjem.

## Napomena
Svi signali koji ulaze u bodovanje se zaista koriste pri rangiranju. Skor direktno odreduje redoslijed preporuka.
