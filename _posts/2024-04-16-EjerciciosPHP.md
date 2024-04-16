1. **Imprimir "Hola, mundo!" en pantalla:**

```php
<?php echo "Hola, mundo!"; ?>
```

2. **Sumar dos números:**

```php
<?php $num1 = 5; $num2 = 3; $suma = $num1 + $num2; echo "La suma de $num1 y $num2 es: $suma"; ?>
```

3. **Calcular el área de un rectángulo:**

```php
<?php $base = 10; $altura = 5; $area = $base * $altura; echo "El área del rectángulo es: $area"; ?>
```
4. **Imprimir los números del 1 al 10:**

```php
<?php for ($i = 1; $i <= 10; $i++) {     echo "$i "; } ?>
```

5. **Determinar si un número es par o impar:**

```php
<?php $num = 6; if ($num % 2 == 0) {     echo "$num es un número par"; } else {     echo "$num es un número impar"; } ?>
```

6.**Calcular el factorial de un número:**

```php
<?php $num = 5; $factorial = 1; for ($i = 1; $i <= $num; $i++) {     $factorial *= $i; } echo "El factorial de $num es: $factorial"; ?>
```

7. **Calcular el promedio de un arreglo de números:**

```php
<?php $numeros = array(10, 15, 20, 25, 30); $total = count($numeros); $suma = array_sum($numeros); $promedio = $suma / $total; echo "El promedio de los números es: $promedio"; ?>
```

8. **Generar una tabla de multiplicar de un número específico:**

```php
<?php $num = 7; echo "Tabla de multiplicar del $num: <br>"; for ($i = 1; $i <= 10; $i++) {     echo "$num x $i = " . ($num * $i) . "<br>"; } ?>
```

9. **Contar las vocales en una cadena de texto:**

```php
<?php $texto = "Hola mundo"; $vocales = 0; $vocales = preg_match_all('/[aeiouAEIOU]/', $texto); echo "El número de vocales en '$texto' es: $vocales"; ?>
```

10. **Invertir una cadena de texto:**

```php
<?php $texto = "Hola mundo"; $invertido = strrev($texto); echo "La cadena invertida es: $invertido"; ?>
```
