String.prototype.isNumber = function() {
    return /^\d+$/.test(this)
}

const roomsCard = document.getElementById('rooms-card')
const rooms = document.getElementById('rooms')
const roomSearchButton = document.getElementById('room-search-btn')
const roomMinicardContainer = document.querySelector('[room-minicard-container]')
const roomMiniCardTemplate = document.querySelector("[room-minicard-template]")

function areValidInputs (checkInDate, checkOutDate, guests) {
    
    if (checkInDate.trim() == '' || checkOutDate.trim() == '' || guests.trim() == '') {
        window.alert('Please fillup the check-in and check-out dates and guests first')
        return false
    } else if(!guests.isNumber()) {
        window.alert('Invalid number of guests')
        return false
    } 

    return true
}

roomSearchButton.onclick = function () {
    const checkInDate = roomsCard.querySelector('#checkIn').value
    const checkOutDate = roomsCard.querySelector('#checkOut').value
    const guests = roomsCard.querySelector('#guestsInput').value

    if(areValidInputs(checkInDate, checkOutDate, guests)) {
        const info = document.getElementById(["info"])
        const houseId = info.getAttribute("data-house-id")

        roomMinicardContainer.innerHTML = ""

        fetch("/availableRooms/" + houseId + '/' + checkInDate + '/' + checkOutDate + '/' + guests)
        .then(response => response.json())
        .then(rooms => {
            if(rooms != null) {
                rooms.rooms.forEach(room => {
                    const roomMiniCard = roomMiniCardTemplate.content.cloneNode(true).children[0]
                    const roomNoText = roomMiniCard.querySelector("[room-no]")
                    const guestsText = roomMiniCard.querySelector("[guests]")
                    const roomPriceText = roomMiniCard.querySelector("[room-price]")
                    const roomReservationButton = roomMiniCard.querySelector("[reservation-button]")

                    const roomNo = room.ROOM_NO

                    roomMiniCard.setAttribute("data-room-no", roomNo)
                    roomNoText.textContent = 'Room No: ' + roomNo
                    guestsText.textContent = 'Max ' + room.MAX_CAPACITY + ' guests allowed'
                    roomPriceText.textContent = '$' + room.PRICE
                    roomReservationButton.setAttribute("data-room-no", roomNo)

                    roomReservationButton.onclick = function () {
                        location.href = '/reservation/' + houseId + '/' + roomNo + '/' + checkInDate + '/' + checkOutDate + '/' + guests
                    }

                    roomMinicardContainer.append(roomMiniCard)
                })
            } else {
                info.getElementsByTagName('p').textContent = 'No available rooms in this criteria'
            }
        })
    }
}

rooms.querySelectorAll(["button"]).forEach(button => {    
    const houseId = button.getAttribute('id').split('-')[1]
    const roomNo = button.getAttribute('id').split('-')[2]

    button.onclick = function () {
        const checkInDate = roomsCard.querySelector('#checkIn').value
        const checkOutDate = roomsCard.querySelector('#checkOut').value
        const guests = roomsCard.querySelector('#guestsInput').value

        if(areValidInputs(checkInDate, checkOutDate, guests)) {
            location.href = '/reservation/' + houseId + '/' + roomNo + '/' + checkInDate + '/' + checkOutDate + '/' + guests
        }
    }
})



// Date Picker start
var from = $('#checkIn').datepicker({
    dateFormat: "dd-M-yy",
    changeMonth: true,
    changeYear: true,
    minDate: 0
})
.on("change", function() {
    to.datepicker("option", "minDate", getDate(this))
})

var to = $("#checkOut").datepicker({
    dateFormat: "dd-M-yy",
    changeMonth: true,
    changeYear: true,
    minDate: 0
})
.on("change", function() {
    from.datepicker("option", "maxDate", getDate(this))
})

function getDate(element) {
    var date
    let dateFormat = "dd-M-yy"
    try{
        date = $.datepicker.parseDate(dateFormat, element.value)
    } catch(error) {
        date = null
    }

    return date
}
// Date picker end

