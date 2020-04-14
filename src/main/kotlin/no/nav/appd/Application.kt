package no.nav.appd

import io.ktor.application.*
import io.ktor.http.ContentType
import io.ktor.response.*
import io.ktor.request.*
import io.ktor.routing.get
import io.ktor.routing.post
import io.ktor.routing.routing
import io.ktor.server.engine.embeddedServer
import io.ktor.server.netty.Netty

fun main() {
    val server = embeddedServer(Netty, 7070) {
        routing {
            get("/") {
                call.respondText("Hello, world!", ContentType.Text.Html)
            }

            get("/isAlive") {
                call.respondText("OK")
            }

            get("/isReady") {
                call.respondText("OK")
            }

            post("/") {
                call.respondText(call.receiveText())
            }
        }
    }
    server.start(wait = true)
}
