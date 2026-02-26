# Syntax Directed Translation with Jison

Jison is a tool that receives as input a Syntax Directed Translation and produces as output a JavaScript parser  that executes
the semantic actions in a bottom up ortraversing of the parse tree.
 

## Compile the grammar to a parser

See file [grammar.jison](./src/grammar.jison) for the grammar specification. To compile it to a parser, run the following command in the terminal:
``` 
➜  jison git:(main) ✗ npx jison grammar.jison -o parser.js
```

## Use the parser

After compiling the grammar to a parser, you can use it in your JavaScript code. For example, you can run the following code in a Node.js environment:

```
➜  jison git:(main) ✗ node                                
Welcome to Node.js v25.6.0.
Type ".help" for more information.
> p = require("./parser.js")
{
  parser: { yy: {} },
  Parser: [Function: Parser],
  parse: [Function (anonymous)],
  main: [Function: commonjsMain]
}
> p.parse("2*3")
6
```

## Cuestiones teóricas

### Describa la diferencia entre /* skip whitespace */ y devolver un token

La diferencia fundamental reside en la **interacción entre el analizador léxico (lexer) y el analizador sintáctico (parser)** durante el procesamiento de la entrada de la calculadora. Cuando el lexer identifica un patrón de texto que coincide con la expresión regular `\s+`, que representa los espacios en blanco, ejecuta el bloque de código asociado que únicamente contiene un comentario de JavaScript `/* skip whitespace */`. Al no existir una instrucción `return`, el lexer simplemente **consume** esos caracteres de la entrada y continúa con la búsqueda del siguiente patrón de forma interna, por lo que el **parser** nunca llega a recibir notificación de estos caracteres y estos resultan totalmente transparentes para la estructura de la gramática. Por el contrario, cuando el lexer reconoce un patrón como `NUMBER` o `OP`, utiliza la instrucción `return` para detener su ejecución y entregar dicha unidad o "token" al **analizador sintáctico**. En este punto, el parser toma el control para evaluar si ese token es coherente con las reglas gramaticales definidas, como $E \rightarrow T$, y determinar si la estructura de la expresión es válida o debe generar un error de sintaxis. En conclusión, **ignorar** sirve para limpiar la entrada de elementos de formato que no aportan significado, mientras que **devolver un token** proporciona los componentes esenciales con los que el parser construye la lógica de la traducción dirigida por la sintaxis.

### Escriba la secuencia exacta de tokens producidos para la entrada 123**45+@

Por lo tanto, la secuencia completa de tokens es: **NUMBER (123) → OP (\*\*) → NUMBER (45) → OP (+) → INVALID (@) → EOF**.

### Indique por qué ** debe aparecer antes que [-+*/]

El hecho de que el patrón `**` deba aparecer antes que `[-+*/]` se debe al **principio de prioridad por orden de aparición** que aplica el analizador léxico. Cuando el lexer lee la entrada, intenta hacer coincidir la cadena con las expresiones regulares en el orden en que están definidas en el bloque `%lex`.

Si el patrón `[-+*/]` se definiera primero, al encontrar la secuencia `**`, el lexer identificaría el primer carácter `*` como un operador individual de multiplicación y devolvería un token `OP`. Acto seguido, volvería a encontrar otro `*` y devolvería un segundo token `OP`. Sin embargo, al colocar `**` en primer lugar, el lexer identifica la secuencia completa como el operador de potencia antes de evaluar las reglas individuales, permitiendo que se reconozca como un único componente léxico.

### Explique cuándo se devuelve EOF.

El token **EOF** (*End Of File*) se devuelve cuando el analizador léxico detecta que se ha alcanzado el **final de la cadena de entrada** y no hay más caracteres por procesar. Su función principal es notificar al **analizador sintáctico** (parser) que la lectura de la expresión ha terminado. Esto permite que el parser valide si la estructura reconocida hasta ese momento está completa y es correcta, procediendo entonces a realizar el cálculo final del valor de la expresión a través de la regla semántica correspondiente.

### Explique por qué existe la regla . que devuelve INVALID.

La regla que devuelve el token **INVALID** existe como un mecanismo de **gestión de errores léxicos**. Su función principal es capturar cualquier carácter o secuencia de texto introducida por el usuario que no coincida con las reglas definidas anteriormente, como los números o los operadores permitidos. Sin esta regla, el analizador léxico se detendría abruptamente al encontrar un carácter inesperado (como un símbolo `@` o `$`); al devolver **INVALID**, el lexer puede informar al **parser** de la presencia de un elemento extraño, permitiendo que el sistema gestione el error de forma controlada en lugar de colapsar.
