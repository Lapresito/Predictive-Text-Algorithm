{ Tarea 2}
{ Grupo 360 }
{ Joaquin Laprovitera - Facundo Delgado }


{ Subprograma 1 }
function hash( SEMILLA, PASO, N: Natural; p: Palabra ): Natural;
var i: integer;
    acc: Natural;
begin
    { Inicialización de acumulador }
    acc:= SEMILLA;
    { Iteración por caracter de array de palabra asignando al acumulador }
    for i:= 1 to p.tope do
        acc:= (acc * PASO) + ord(p.cadena[i]);
    { Asignación de valor a devolver }
    hash:= acc mod N
end;

{ Subprograma 2 }
function comparaPalabra ( p1, p2 : Palabra ) : Comparacion;
var
    i,mT: integer; {mT = menor tope}
    res: Comparacion;

begin
    i:= 1;
    { Selección de menor tope }
    mT:= p1.tope;
    if mT > p2.tope then
        mT := p2.tope;
    { Inicialización de resultado }
    res := igual;
    { Búsqueda de menor o mayor }
    while (i <= mT) and (res = igual) do 
    begin
        if p1.cadena[i] > p2.cadena[i] then
            res := mayor
        else
        if p1.cadena[i] < p2.cadena[i] then
            res := menor
        else
            res := igual;

        i:= i + 1;
    end;
    { Validación de resultado del bucle }
    if (res = igual) then
        begin
            if p1.tope > p2.tope then 
                res := mayor
            else 
            if p1.tope < p2.tope then
                res := menor
        end;
    { Asignación de valor a devolver }
    comparaPalabra := res;
end;

{ Subprograma 3 }
function mayorPalabraCant( pc1, pc2: PalabraCant ): boolean;
var res: boolean;
begin
    { Inicialización de resultado }
    res:= false;
    if (pc1.cant > pc2.cant) then
        res:= true
    { Si las cantidades son iguales, comparación por orden lexicográfico }
    else if ( pc1.cant = pc2.cant ) and (comparaPalabra(pc1.pal, pc2.pal) = mayor) then
        res:= true;
    { Asignación de valor a devolver }
    mayorPalabraCant:= res

end;

{ Subprograma 4 }
procedure agregarOcurrencia(p: Palabra; var pals: Ocurrencias);
var ocurrencia, busqueda: Ocurrencias;
begin
    { Inicialización de puntero para realizar búsqueda sobre lista de Ocurrencias }
    busqueda := pals;
    { Si la lista apunta a nil (no tiene ocurrencias), la crea y la agrega }
    if( busqueda = nil ) then
    begin
        new(ocurrencia);
        ocurrencia^.palc.pal := p;
        ocurrencia^.palc.cant := 1;
        ocurrencia^.sig := nil;
        pals:= ocurrencia;
    end
    else
    begin
        { Busqueda de la palabra en la lista }
        while (busqueda^.sig <> nil) and (comparaPalabra(busqueda^.palc.pal, p) <> igual) do
            busqueda := busqueda^.sig;
        { Si la encuentra y se encuentra en el medio de la lista, le suma cantidad }
        if( busqueda^.sig <> nil) and (comparaPalabra(busqueda^.palc.pal, p) = igual) then
            busqueda^.palc.cant := busqueda^.palc.cant + 1
        { Si la encuentra y se encuentra al final de la lista, le suma cantidad (caso borde)}
        else if (busqueda^.sig = nil) and (comparaPalabra(busqueda^.palc.pal, p) = igual) then
            busqueda^.palc.cant := busqueda^.palc.cant + 1
        else
        { Si no la encuentra, la agrega al final de la lista }
        begin
            new(ocurrencia);
            ocurrencia^.palc.pal := p;
            ocurrencia^.palc.cant := 1;
            ocurrencia^.sig := nil;
            busqueda^.sig := ocurrencia;
        end;
    end;
end;

{ Subprograma 5 }
procedure inicializarPredictor ( var pred: Predictor );
var
    i : integer;
begin
    { Recorrida entera del array inicializando las listas apuntando a nil }
    for i := 1 to MAXHASH do 
    begin
        pred[i] := nil;
    end;
end;

{ Subprograma 6 }
procedure entrenarPredictor( txt: Texto; var pred: Predictor );
var p1, p2: Texto;
    codHash: Natural;
begin
    { Asignación de la primer palabra como la primer palabra del texto. }
    p1:= txt;
    if (p1 <> nil) then
    begin
        p2:= p1^.sig;
        while (p2 <> nil) do
        begin
            codHash:= hash(SEMILLA, PASO, MAXHASH, p1^.info);
            agregarOcurrencia(p2^.info, pred[codHash]);
            p1:= p2;
            p2:=p1^.sig;
        end;
    end;
end;

{ Subprograma 7 }
procedure insOrdAlternativas(pc: PalabraCant; var alts: Alternativas);
{ Subprograma para intercambiar valores }
procedure intercambio(var a, b: PalabraCant);
var temp: PalabraCant;
begin
    temp := a;
    a := b;
    b := temp;
end;
{ Subprograma de ordenamiento por insercion }
procedure OrdIns(var A: Alternativas);
var i, j: 1..MAXALTS;
begin
    for i := 2 to A.tope do
    begin
        j := i;
        while (j >= 2) and (mayorPalabraCant(A.pals[j], A.pals[j - 1])) do
        begin
            intercambio(A.pals[j], A.pals[j - 1]);
            j := j - 1;
        end;
    end;
end;
{ Subprograma de busqueda de algun elemento de Alternativas que su cant sea menor que la palabra evaluada }
function buscarMenor(palc: PalabraCant; alterns: Alternativas): boolean;
{ Pre-condición: Array Alternativas debe estar lleno (tope = MAXALTS) }
var res: boolean;
    i: integer;
begin
    res := false;
    i := 1;
    while (i <= alterns.tope) and (not mayorPalabraCant(palc, alterns.pals[i])) do
        i := i + 1;
    res := (i <= alterns.tope); { Devuelve true si se encuentra al menos una palabra con cantidad menor }
    buscarMenor := res;
end;

begin
{ Identificación de si el array de Alternativas está completo }
    if alts.tope < MAXALTS then
  { Si no lo está, agrega elemento y luego ordena }
    begin
        alts.tope := alts.tope + 1;
        alts.pals[alts.tope] := pc;
        OrdIns(alts);
    end
  { Si está lleno (tope = MAXALTS ), utiliza buscarMenor para saber si debería ingresar al array }
    else if(buscarMenor(pc, alts)) then
    begin
    { Si encuentra una palabra menor, se inserta al final y luego se ordena }
        alts.pals[MAXALTS] := pc;
        OrdIns(alts);
    end;
end;

{ Subprograma 8 }
procedure obtenerAlternativas( p: Palabra; pred: Predictor; var alts: Alternativas );
var indice: Ocurrencias;
    codHash: Natural;
begin
    { Vacio el array alts al dejar tope en 0, evitando posibles desechos }
    alts.tope:=0;
    { Utilización de function hash para colocar en indice en array Preditor}
    codHash := hash(SEMILLA, PASO, MAXHASH, p);
    indice := pred[codHash];
    { Iteración en lista de palabra aplicandole procedimiento}
    while (indice <> nil) do
    begin
        insOrdAlternativas(indice^.palc, alts);
        indice:= indice^.sig
    end;
end;