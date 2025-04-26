// Apellido y Nombre: Gegon Franco

// Departamento de la Muerte
object departamentoDeLaMuerte {
    const paquetesDeLaEmpresa = paquetesPredefinidos
    const agentes = []

    method agregarAgente(agente) {
        agentes.add(agente)
    }

    method mejorAgente() = agentes.max{agente => agente.cantidadPaquetesVendidos()}

    method pasarElDiaDelosMuertos() {
        agentes.mejorAgente().disminuirDeuda(50)
        agentes.forEach({agente => self.chequearDeuda(agente)})
    }

    method chequearDeuda(agente) {
        if (agente.deudaActual() == 0)
            agentes.remove(agente)
        else 
            agente.aumentarDeuda(100)
    } 


}

// Paquetes predefinidos de la empresa
object paquetesPredefinidos {
   const paquetes = []

   method agregarPaquete(paquete) = paquetes.add(paquete) 
}

// Agente
class Agente {
    var property deuda
    const paquetesDeLaEmpresa = paquetesPredefinidos
    const paquetesVendidos = []
    var estrategia

    method venderPaquete(paquete , alma) {
        if (alma.leAlcanza(paquete)){
            self.disminuirDeuda(paquete.costo())
            self.agregarPaqueteVendido(paquete)
            alma.reducirAniosDeviaje(paquete.anios())
        }           
        else 
            throw new DomainException(message = "No hay suficiente capital")
    }

    method disminuirDeuda(nro) {
        deuda -= nro
    }

    method aumentarDeuda(nro) {
        deuda += nro
    }


    method agregarPaqueteVendido(paquete) {
        paquetesVendidos.add(paquete)
    }

    method dineroTotalGanado() = paquetesVendidos.sum{paquete => paquete.costo()}

    method deudaActual() = 0.max(deuda) //En caso de que el costo del paquete vendido supere el de la deuda

    method cantidadPaquetesVendidos() = paquetesVendidos.size()

    method cambiarDeEstrategia(estrategiaNueva) {
        estrategia = estrategiaNueva
    }

    method atenderAlma(alma) {
        self.venderPaquete(self.paqueteArmado(alma), alma)
    }

    method paqueteArmado(alma) = estrategia.armarPaquete(alma)
}

// Alma
class Alma {
    const property dineroAlMorir
    const property accionesBuenas 
    var property aniosDeViaje = 4

    method capitalDeAlma() = dineroAlMorir + accionesBuenas

    method reducirAniosDeviaje(n) {
        aniosDeViaje -= n
    }

    method leAlcanza(paquete) = paquete.costo() <= self.capitalDeAlma() 

}

// Paquetes
class Paquete {
    const property valorBasico

    method anios()

    method costo() = 350.min(self.costoBasico())

    method costoBasico() = valorBasico * self.anios()
}

class PaqueteTren inherits Paquete {

    override method anios() = 4
}

class PaqueteBote inherits Paquete {
    const alma

    override method anios() = 2.min(alma.accionesBuenas() / 50)
}

class PaqueteCrucero inherits PaqueteBote {

    override method anios() = super() * 2
}

class PaquetePaloConBrujula inherits Paquete {

    override method anios() = 0.05

    override method costo() = valorBasico 
}

// Estrategias
object estrategiaClasica {

    method armarPaquete(alma) = self.armarPaquete(paquetesPredefinidos, alma)

    method armarPaquete(paquetesPredefinidos, alma) {
     return self.paqueteMasCaroParaAlma(alma, paquetesPredefinidos)  
    }

    method paqueteMasCaroParaAlma(alma,paquetesPredefinidos) = paquetesPredefinidos.filter{paquete => alma.leAlcanza(paquete)}.max{paquete => paquete.costo()}
}

object estrategiaNavegante {

    method armarPaquete(alma) {
        if (alma.accionesBuenas() >= 50)
            return new PaqueteCrucero (alma = alma , valorBasico = alma.accionesBuenas())
        else return new PaqueteBote (alma = alma , valorBasico = alma.accionesBuenas())
    }
}

object estrategiaIndiferente {

    method armarPaquete(alma) {
      return new PaquetePaloConBrujula (valorBasico = 1.randomUpTo(300) )
    }
}
